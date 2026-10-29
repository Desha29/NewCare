import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';

void main() {
  test('drawer must be checked by current nursing before closing and closure persists', () async {
    final store = MemoryStringStore(),
        repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    final expected = repo.current.expectedCash(repo.current.activeShift!);
    await expectLater(
      repo.endShift(
        '',
        countedMinor: expected,
        checkedBy: 'n3',
        verifiedExpectedMinor: expected,
      ),
      throwsA(isA<WorkspaceException>()),
    );
    await expectLater(
      repo.endShift(
        '',
        countedMinor: expected - 100,
        checkedBy: 'n1',
        verifiedExpectedMinor: expected,
      ),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.endShift(
      'All checked',
      countedMinor: expected - 100,
      checkedBy: 'n2',
      verifiedExpectedMinor: expected,
      differenceReason: 'Counted shortage',
    );
    final closed = repo.current.shifts.last;
    expect(repo.current.activeShift, isNull);
    expect(closed.closedAt, isNotNull);
    expect(closed.drawerCheckedAt, isNotNull);
    expect(closed.drawerCheckedBy, 'n2');
    expect(closed.closingCountedMinor, expected - 100);
    expect(closed.closingExpectedMinor, expected);
    expect(closed.closingDifferenceReason, 'Counted shortage');
    await store.write(
      LocalWorkspaceRepository.storageKey,
      (await repo.store.read(LocalWorkspaceRepository.storageKey))!,
    );
    final reloaded = LocalWorkspaceRepository(store);
    await reloaded.initialize();
    expect(reloaded.current.shifts.last.drawerCheckedBy, 'n2');
    await repo.dispose();
    await reloaded.dispose();
  });
  test(
    'new cash movement invalidates the reviewed amount before atomic closure',
    () async {
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      final expected = repo.current.expectedCash(repo.current.activeShift!);
      await repo.addMovement(
        CashMovement(
          id: 'late-expense',
          shiftId: 'shift-demo',
          staffId: 'n1',
          kind: CashKind.expense,
          amountMinor: 100,
          reason: 'New expense',
          createdAt: DateTime.now(),
        ),
      );
      await expectLater(
        repo.endShift(
          '',
          countedMinor: expected,
          checkedBy: 'n1',
          verifiedExpectedMinor: expected,
        ),
        throwsA(isA<WorkspaceException>()),
      );
      expect(repo.current.activeShift, isNotNull);
      await repo.dispose();
    },
  );
}
