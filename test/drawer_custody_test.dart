import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/drawer/data/models/drawer_handover.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';
import 'package:newcare/features/analytics/data/models/report_summary.dart';

void main() {
  test('external advances and cash custody remain independent of shifts and payroll', () async {
    final store = MemoryStringStore();
    final repo = LocalWorkspaceRepository(store);
    await repo.initialize();
    final before = repo.current.drawerBalance;
    await expectLater(
      repo.addMovement(
        CashMovement(
          id: 'invalid',
          shiftId: '',
          staffId: 'n1',
          kind: CashKind.externalAdvance,
          amountMinor: 10000,
          reason: 'External advance',
          createdAt: DateTime.now(),
        ),
      ),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.addMovement(
      CashMovement(
        id: 'external',
        shiftId: '',
        staffId: 'n1',
        kind: CashKind.externalAdvance,
        recipient: 'أحمد الخارجي',
        amountMinor: 10000,
        reason: 'External advance',
        createdAt: DateTime.now(),
      ),
    );
    expect(repo.current.drawerBalance, before - 10000);
    expect(
      ReportSummary.forRange(
        repo.current,
        DateTime.now(),
        DateTime.now(),
      ).advanceMinor,
      0,
    );
    final expected = repo.current.drawerBalance;
    final bad = DrawerHandover(
      id: 'missing-note',
      fromStaffId: 'n1',
      toStaffId: 'n2',
      expectedMinor: expected,
      countedMinor: expected - 500,
      at: DateTime.now(),
    );
    await expectLater(
      repo.handoverDrawer(bad),
      throwsA(isA<WorkspaceException>()),
    );
    final checked = DrawerHandover(
      id: 'h1',
      fromStaffId: 'n1',
      toStaffId: 'n2',
      expectedMinor: expected,
      countedMinor: expected - 500,
      note: 'فرق في العد',
      at: DateTime.now(),
    );
    await repo.handoverDrawer(checked);
    await repo.handoverDrawer(checked);
    expect(repo.current.handovers, hasLength(1));
    expect(repo.current.drawerHolder, 'n2');
    expect(repo.current.drawerBalance, expected - 500);
    expect(repo.current.handovers.single.statusKey, 'drawerShortage');
    await expectLater(
      repo.handoverDrawer(
        DrawerHandover(
          id: 'stale',
          fromStaffId: 'n2',
          toStaffId: 'n1',
          expectedMinor: expected,
          countedMinor: expected,
          at: DateTime.now(),
        ),
      ),
      throwsA(isA<WorkspaceException>()),
    );
    final restored = LocalWorkspaceRepository(store);
    await restored.initialize();
    expect(restored.current.drawerBalance, expected - 500);
    expect(restored.current.movements.single.recipient, 'أحمد الخارجي');
    await repo.dispose();
    await restored.dispose();
  });
}
