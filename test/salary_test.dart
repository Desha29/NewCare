import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';

void main() {
  test(
    'salary and optional phone are backward compatible and persist edits',
    () async {
      expect(
        NursingMember.fromJson({'id': 'old', 'name': 'Old'}).salaryMinor,
        0,
      );
      final store = MemoryStringStore(),
          repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await repo.updateRecord(ManagedRecordKind.nursing, 'n1', {
        'salary': 650000,
        'phone': '01012345678',
      }, 'Salary agreed');
      expect(repo.current.staff.first.salaryMinor, 650000);
      expect(repo.current.staff.first.phone, '01012345678');
      expect(repo.current.audit.last.reason, 'Salary agreed');
      await expectLater(
        repo.updateRecord(ManagedRecordKind.nursing, 'n1', {
          'salary': -1,
        }, 'Invalid'),
        throwsA(isA<WorkspaceException>()),
      );
      await store.write(
        LocalWorkspaceRepository.storageKey,
        (await repo.store.read(LocalWorkspaceRepository.storageKey))!,
      );
      final reloaded = LocalWorkspaceRepository(store);
      await reloaded.initialize();
      expect(reloaded.current.staff.first.salaryMinor, 650000);
      await repo.dispose();
      await reloaded.dispose();
    },
  );
  test('manager advance can belong to nursing outside current shift and reduces cash', () async {
    final repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    final before = repo.current.expectedCash(repo.current.activeShift!);
    await repo.addMovement(
      CashMovement(
        id: 'advance',
        shiftId: 'shift-demo',
        staffId: 'n3',
        kind: CashKind.advance,
        amountMinor: 10000,
        reason: 'Salary advance',
        createdAt: DateTime.now(),
      ),
    );
    expect(
      repo.current.expectedCash(repo.current.activeShift!),
      before - 10000,
    );
    await expectLater(
      repo.updateRecord(ManagedRecordKind.movement, 'advance', {
        'staff': 'missing',
      }, 'Correct recipient'),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.dispose();
  });
}
