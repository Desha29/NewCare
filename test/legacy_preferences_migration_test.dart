import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/legacy_store_migration.dart';
import 'package:newcare/core/storage/string_store.dart';

class _Legacy extends MemoryStringStore implements RemovableStringStore {
  bool backupVerified = false;
  final deleted = <String>[];
  @override
  Future<void> remove(String key) async {
    expect(
      backupVerified,
      isTrue,
      reason: 'Never delete before protected backup verification',
    );
    deleted.add(key);
    await super.remove(key);
  }
}

void main() {
  test(
    'sensitive preferences are removed only after verified protected backup',
    () async {
      final legacy = _Legacy(), target = MemoryStringStore();
      await legacy.write('newcare.workspace.v1', 'private-medical-workspace');
      await migrateLegacyStore(
        legacy: legacy,
        target: target,
        verifyProtectedBackup: (values) async {
          expect(
            await target.read('newcare.workspace.v1'),
            'private-medical-workspace',
          );
          expect(values['newcare.workspace.v1'], 'private-medical-workspace');
          legacy.backupVerified = true;
        },
      );
      expect(await legacy.read('newcare.workspace.v1'), isNull);
      expect(
        await target.read('newcare.workspace.v1'),
        'private-medical-workspace',
      );
      expect(legacy.deleted, contains('newcare.workspace.v1'));
    },
  );
  test(
    'backup failure retains original and retries without overwriting data',
    () async {
      final legacy = _Legacy(), target = MemoryStringStore();
      await legacy.write('newcare.workspace.v1', 'preserved');
      await expectLater(
        migrateLegacyStore(
          legacy: legacy,
          target: target,
          verifyProtectedBackup: (_) async =>
              throw StateError('backup unavailable'),
        ),
        throwsStateError,
      );
      expect(await legacy.read('newcare.workspace.v1'), 'preserved');
      expect(legacy.deleted, isEmpty);
      await migrateLegacyStore(
        legacy: legacy,
        target: target,
        verifyProtectedBackup: (_) async {
          legacy.backupVerified = true;
        },
      );
      expect(await target.read('newcare.workspace.v1'), 'preserved');
      expect(await legacy.read('newcare.workspace.v1'), isNull);
    },
  );
  test('conflicting legacy data is preserved for manual recovery', () async {
    final legacy = _Legacy(), target = MemoryStringStore();
    await legacy.write('newcare.workspace.v1', 'older-legacy');
    await target.write('newcare.workspace.v1', 'newer-encrypted');
    await expectLater(
      migrateLegacyStore(
        legacy: legacy,
        target: target,
        verifyProtectedBackup: (_) async {
          fail('No backup should hide a conflict');
        },
      ),
      throwsStateError,
    );
    expect(await legacy.read('newcare.workspace.v1'), 'older-legacy');
    expect(await target.read('newcare.workspace.v1'), 'newer-encrypted');
  });
}
