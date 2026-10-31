import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/laboratory/data/models/lab_order.dart';
import 'package:newcare/features/laboratory/data/models/lab_order_item.dart';
import 'package:newcare/features/laboratory/data/models/lab_payment.dart';
import 'package:newcare/features/laboratory/data/models/lab_test.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';

class _Store extends MemoryStringStore {
  bool fail = false;
  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('unavailable');
    await super.write(key, value);
  }
}

void main() {
  late _Store store;
  late LocalWorkspaceRepository repo;

  setUp(() async {
    store = _Store();
    repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await repo.addStaff(const NursingMember(id: 'nurse-1', name: 'Nurse'));
    await repo.saveLabTest(const LabTest(id: 't1', name: 'CBC', priceMinor: 10000)); // 100 EGP
    await repo.saveLabTest(const LabTest(id: 't2', name: 'Liver Functions', priceMinor: 20000)); // 200 EGP
  });

  tearDown(() async => repo.dispose());

  test('300 total, 100 cash + 200 wallet collects properly and updates drawer & remaining', () async {
    final order = LabOrder(
      id: 'order-1',
      patientName: 'Ahmed',
      patientAge: 35,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
        LabOrderItem(testId: 't2', name: 'Liver Functions', priceMinor: 20000),
      ],
    );
    expect(order.totalMinor, 30000);

    // Initial cash payment of 100 EGP
    final p1 = LabPayment(
      id: 'p-1',
      orderId: 'order-1',
      amountMinor: 10000,
      method: PaymentMethod.cash,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
    );
    await repo.addLabOrder(order, initialPayment: p1);

    expect(repo.current.labOrders, hasLength(1));
    expect(repo.current.labPayments, hasLength(1));
    expect(repo.current.paidForLab(repo.current.labOrders.first), 10000);
    expect(repo.current.remainingForLab(repo.current.labOrders.first), 20000);
    expect(repo.current.drawerBalance, 10000); // 100 EGP cash in drawer

    // Later wallet payment of 200 EGP
    final p2 = LabPayment(
      id: 'p-2',
      orderId: 'order-1',
      amountMinor: 20000,
      method: PaymentMethod.wallet,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 11),
    );
    await repo.addLabPayment(p2);

    expect(repo.current.labPayments, hasLength(2));
    expect(repo.current.paidForLab(repo.current.labOrders.first), 30000);
    expect(repo.current.remainingForLab(repo.current.labOrders.first), 0);
    expect(repo.current.drawerBalance, 10000); // Wallet does NOT increase cash drawer
  });

  test('unpaid order creates no payment receipt and leaves drawer at zero', () async {
    final order = LabOrder(
      id: 'order-2',
      patientName: 'Mona',
      patientAge: 28,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );
    await repo.addLabOrder(order);

    expect(repo.current.labOrders, hasLength(1));
    expect(repo.current.labPayments, isEmpty);
    expect(repo.current.paidForLab(order), 0);
    expect(repo.current.remainingForLab(order), 10000);
    expect(repo.current.drawerBalance, 0);
  });

  test('cannot overpay order and payments must be positive', () async {
    final order = LabOrder(
      id: 'order-3',
      patientName: 'Ali',
      patientAge: 40,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );
    await repo.addLabOrder(order);

    // Negative or zero payment throws
    await expectLater(
      repo.addLabPayment(LabPayment(
        id: 'p-neg',
        orderId: 'order-3',
        amountMinor: 0,
        method: PaymentMethod.cash,
        staffId: 'nurse-1',
        createdAt: DateTime.now(),
      )),
      throwsA(isA<WorkspaceException>()),
    );

    // Overpayment throws
    await expectLater(
      repo.addLabPayment(LabPayment(
        id: 'p-over',
        orderId: 'order-3',
        amountMinor: 15000,
        method: PaymentMethod.cash,
        staffId: 'nurse-1',
        createdAt: DateTime.now(),
      )),
      throwsA(isA<WorkspaceException>()),
    );
  });

  test('rejects stale prices when catalogue price changes during open draft', () async {
    final staleOrder = LabOrder(
      id: 'order-stale',
      patientName: 'Kareem',
      patientAge: 12,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 8000), // Stale: catalog is 10000
      ],
    );

    await expectLater(
      repo.addLabOrder(staleOrder),
      throwsA(isA<WorkspaceException>()),
    );
  });

  test('result receipt status is independent of payment and is idempotent', () async {
    final order = LabOrder(
      id: 'order-4',
      patientName: 'Sara',
      patientAge: 22,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );
    await repo.addLabOrder(order); // Unpaid

    expect(repo.current.labOrders.first.received, isFalse);

    // Mark received without payment
    await repo.setLabReceived('order-4', 'nurse-1', received: true);
    final after1 = repo.current.labOrders.first;
    expect(after1.received, isTrue);
    expect(after1.receivedBy, 'nurse-1');
    expect(after1.receivedAt, isNotNull);
    expect(repo.current.paidForLab(after1), 0); // Still unpaid!
    expect(repo.current.drawerBalance, 0); // No money generated

    // Idempotent: calling again does not change receivedAt or duplicate
    final firstReceivedAt = after1.receivedAt;
    await repo.setLabReceived('order-4', 'nurse-1', received: true);
    expect(repo.current.labOrders.first.receivedAt, firstReceivedAt);
  });

  test('catalogue rename and price edits do not affect historical orders', () async {
    final order = LabOrder(
      id: 'order-5',
      patientName: 'Hassan',
      patientAge: 50,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );
    await repo.addLabOrder(order);

    // Now update catalog test t1 price and name
    await repo.saveLabTest(const LabTest(id: 't1', name: 'Complete Blood Count', priceMinor: 15000, version: 1));

    // Historical order retains original name and price
    final savedOrder = repo.current.labOrders.firstWhere((o) => o.id == 'order-5');
    expect(savedOrder.items.first.name, 'CBC');
    expect(savedOrder.items.first.priceMinor, 10000);
    expect(savedOrder.totalMinor, 10000);
  });

  test('persistence failure rolls back order and payment cleanly', () async {
    final before = repo.current;
    store.fail = true;

    final order = LabOrder(
      id: 'order-fail',
      patientName: 'FailTest',
      patientAge: 30,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );

    await expectLater(repo.addLabOrder(order), throwsStateError);
    expect(identical(repo.current, before), isTrue);

    store.fail = false;
    await repo.addLabOrder(order);
    expect(repo.current.labOrders, hasLength(1));
  });

  test('manager receipt correction updates lab receipt without exceeding total', () async {
    final order = LabOrder(
      id: 'order-corr',
      patientName: 'Correction Patient',
      patientAge: 40,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
      items: const [
        LabOrderItem(testId: 't1', name: 'CBC', priceMinor: 10000),
      ],
    );
    final payment = LabPayment(
      id: 'p-corr',
      orderId: 'order-corr',
      amountMinor: 5000,
      method: PaymentMethod.cash,
      staffId: 'nurse-1',
      createdAt: DateTime.utc(2026, 10, 31, 10),
    );
    await repo.addLabOrder(order, initialPayment: payment);

    // Correct receipt amount from 5000 to 7000
    await repo.updateRecord(
      ManagedRecordKind.labReceipt,
      'p-corr',
      {'amountMinor': 7000},
      'corrected counted receipt',
    );
    expect(repo.current.labPayments.first.amountMinor, 7000);
    expect(repo.current.drawerBalance, 7000);

    // Correcting above order total (10000) throws
    await expectLater(
      repo.updateRecord(
        ManagedRecordKind.labReceipt,
        'p-corr',
        {'amountMinor': 12000},
        'exceeds total',
      ),
      throwsA(isA<WorkspaceException>()),
    );
  });
}

