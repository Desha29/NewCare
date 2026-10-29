import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/catalogue/data/models/procedure.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';

void main() {
  late LocalWorkspaceRepository repo;
  late MemoryStringStore store;
  setUp(() async {
    store = MemoryStringStore();
    repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await repo.addStaff(const NursingMember(id: 'n1', name: 'Nurse'));
    await repo.addStaff(
      const NursingMember(id: 'n2', name: 'Manager', isManager: true),
    );
    await repo.addProcedure(
      const Procedure(
        id: 'p1',
        nameAr: 'محلول',
        nameEn: 'IV',
        priceMinor: 25000,
      ),
    );
    await repo.saveSettings(openingMinor: 20000);
  });
  tearDown(() async {
    await repo.dispose();
  });
  CaseRecord record({
    CaseLocation location = CaseLocation.inside,
    PaymentMethod payment = PaymentMethod.cash,
    String address = '',
    String staff = 'n1',
  }) => CaseRecord(
    id: 'c1',
    shiftId: repo.current.activeShift?.id ?? '',
    staffId: staff,
    title: 'IV',
    procedureId: 'p1',
    supplies: const [],
    amountMinor: 25000,
    payment: payment,
    location: location,
    createdAt: DateTime.now(),
    address: address,
  );
  test('wallet payments never increase drawer cash', () async {
    await repo.startShift('n1', 20000);
    await repo.addCase(record(payment: PaymentMethod.wallet));
    expect(repo.current.expectedCash(repo.current.activeShift!), 20000);
  });
  test('outside visits require an address but not a phone', () async {
    await repo.startShift('n1', 20000);
    await expectLater(
      repo.addCase(record(location: CaseLocation.outside)),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.addCase(
      record(location: CaseLocation.outside, address: '12 Main Street'),
    );
    expect(repo.current.cases.single.phone, isEmpty);
  });
  test('all active nursing staff can record cases without a shift', () async {
    expect(repo.current.shifts, isEmpty);
    await repo.addCase(record(staff: 'n2'));
    expect(repo.current.cases.single.staffId, 'n2');
  });
  test(
    'drawer variance requires a reason and persists the next opening balance',
    () async {
      await expectLater(
        repo.startShift('n1', 19000),
        throwsA(isA<WorkspaceException>()),
      );
      await repo.startShift('n1', 19000, reason: 'Count difference');
      expect(repo.current.activeShift!.openingMinor, 19000);
      expect(
        repo.current.audit.any((x) => x.action == 'handoverRecorded'),
        isTrue,
      );
    },
  );
  test(
    'one advance creates one drawer deduction and survives reload',
    () async {
      await repo.startShift('n1', 20000);
      final m = CashMovement(
        id: 'm1',
        shiftId: repo.current.activeShift!.id,
        staffId: 'n1',
        kind: CashKind.advance,
        amountMinor: 3000,
        reason: 'Advance',
        createdAt: DateTime.now(),
      );
      await repo.addMovement(m);
      await repo.addMovement(m);
      expect(repo.current.expectedCash(repo.current.activeShift!), 17000);
      final loaded = LocalWorkspaceRepository(store, seedDemo: false);
      await loaded.initialize();
      expect(loaded.current.movements.length, 1);
      expect(loaded.current.expectedCash(loaded.current.activeShift!), 17000);
      await loaded.dispose();
    },
  );
  test('concurrent writes preserve both members', () async {
    await Future.wait([
      repo.addStaff(const NursingMember(id: 'n3', name: 'A')),
      repo.addStaff(const NursingMember(id: 'n4', name: 'B')),
    ]);
    expect(repo.current.staff.length, 4);
  });
}
