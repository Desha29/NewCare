import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/sqlite_string_store.dart';
import 'package:newcare/core/storage/storage_cipher.dart';

void main() {
  late Directory directory;
  late SqliteStringStore store;
  final key = List<int>.generate(32, (i) => i);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('newcare-storage-');
    store = await SqliteStringStore.open(
      path: '${directory.path}/data.db',
      cipher: StorageCipher(key),
    );
  });
  tearDown(() async {
    await store.close();
    await directory.delete(recursive: true);
  });

  test('snapshot and pending operation survive reopening, encrypted', () async {
    await store.commit(
      key: 'workspace',
      value: 'private-patient-address',
      operationId: 'operation-1',
      action: 'caseAdded',
      payload: '{"address":"private-patient-address"}',
    );
    await store.close();
    store = await SqliteStringStore.open(
      path: '${directory.path}/data.db',
      cipher: StorageCipher(key),
    );
    expect(await store.read('workspace'), 'private-patient-address');
    final pending = await store.pending();
    expect(pending.single.id, 'operation-1');
    expect(pending.single.payload, contains('private-patient-address'));
    for (final file in directory.listSync().whereType<File>()) {
      expect(
        String.fromCharCodes(await file.readAsBytes()),
        isNot(contains('private-patient-address')),
      );
    }
  });

  test('a duplicate operation rolls back the accompanying snapshot', () async {
    await store.commit(
      key: 'workspace',
      value: 'first',
      operationId: 'same',
      action: 'caseAdded',
      payload: '{}',
    );
    await expectLater(
      store.commit(
        key: 'workspace',
        value: 'wrong',
        operationId: 'same',
        action: 'cashAdded',
        payload: '{}',
      ),
      throwsA(anything),
    );
    expect(await store.read('workspace'), 'first');
    expect(await store.pending(), hasLength(1));
  });

  test('wrong encryption key fails without replacing stored data', () async {
    await store.write('workspace', 'preserved');
    await store.close();
    store = await SqliteStringStore.open(
      path: '${directory.path}/data.db',
      cipher: StorageCipher(List<int>.filled(32, 99)),
    );
    await expectLater(store.read('workspace'), throwsA(anything));
    await store.close();
    store = await SqliteStringStore.open(
      path: '${directory.path}/data.db',
      cipher: StorageCipher(key),
    );
    expect(await store.read('workspace'), 'preserved');
  });

  test(
    'consistent backup includes pending operations and never overwrites',
    () async {
      await store.commit(
        key: 'workspace',
        value: 'before',
        operationId: 'backup-operation',
        action: 'caseAdded',
        payload: 'encrypted-pending-payload',
      );
      final backup = '${directory.path}/backups/snapshot.db';
      await store.createBackup(backup);
      await store.write('workspace', 'after');
      await expectLater(store.createBackup(backup), throwsA(anything));
      final recovered = await SqliteStringStore.open(
        path: backup,
        cipher: StorageCipher(key),
      );
      try {
        expect(await recovered.read('workspace'), 'before');
        expect((await recovered.pending()).single.id, 'backup-operation');
        expect(await store.read('workspace'), 'after');
      } finally {
        await recovered.close();
      }
    },
  );

  test(
    'acknowledgement requires matching operation and keeps later writes',
    () async {
      for (var i = 0; i < 2; i++) {
        await store.commit(
          key: 'workspace',
          value: '$i',
          operationId: 'op-$i',
          action: 'caseAdded',
          payload: '{}',
        );
      }
      await store.acknowledge('op-0');
      expect((await store.pending()).single.id, 'op-1');
      expect(await store.read('workspace'), '1');
      expect(store.durability.journalMode, 'wal');
      expect(store.durability.synchronous, 2);
      expect(
        store.durability.hasRequiredWalFix,
        isTrue,
        reason: 'The loaded SQLite runtime must be at least 3.51.3',
      );
    },
  );
}
