import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/data/models/case_payment.dart';
import 'package:newcare/features/catalogue/data/models/procedure.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/drawer/data/models/drawer_handover.dart';
import 'package:newcare/features/inventory/data/models/stock_item.dart';
import 'package:newcare/features/inventory/data/models/case_stock_usage.dart';
import 'package:newcare/features/laboratory/data/models/lab_test.dart';
import 'package:newcare/features/laboratory/data/models/lab_order.dart';
import 'package:newcare/features/laboratory/data/models/lab_order_item.dart';
import 'package:newcare/features/laboratory/data/models/lab_payment.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';

/// Synthetic data only, shared by the durable restart and live cloud tests.
Future<void> populateProductionWorkflow(WorkspaceRepository repo) async {
  final at = DateTime.utc(2026, 11, 4, 10);
  await repo.addStaff(
    const NursingMember(id: 'qa-n1', name: 'تمريض تجريبي', salaryMinor: 400000),
  );
  await repo.addStaff(
    const NursingMember(id: 'qa-n2', name: 'تمريض تجريبي ثان'),
  );
  await repo.updateRecord(ManagedRecordKind.nursing, 'qa-n1', {
    'salary': 500000,
  }, 'QA salary');
  await repo.addProcedure(
    const Procedure(id: 'qa-p', nameAr: 'إجراء تجريبي', nameEn: 'QA procedure'),
  );
  await repo.saveStockItem(
    const StockItem(id: 'qa-stock', name: 'شاش تجريبي', quantity: 10),
  );
  await repo.saveSettings(
    openingMinor: 10000,
    setupDone: true,
    managerName: 'QA manager',
  );
  for (final outside in [false, true]) {
    await repo.addCase(
      CaseRecord(
        id: outside ? 'qa-out' : 'qa-in',
        shiftId: '',
        staffId: 'qa-n1',
        title: 'إجراء تجريبي',
        procedureId: 'qa-p',
        supplies: const [],
        agreedTotalMinor: outside ? 5000 : 10000,
        amountMinor: outside ? 3000 : 4000,
        payment: outside ? PaymentMethod.wallet : PaymentMethod.cash,
        location: outside ? CaseLocation.outside : CaseLocation.inside,
        address: outside ? 'عنوان تجريبي فقط' : '',
        createdAt: at,
        stockUsages: [
          CaseStockUsage(
            stockItemId: 'qa-stock',
            name: 'شاش تجريبي',
            quantity: outside ? 1 : 2,
          ),
        ],
      ),
    );
  }
  await repo.addCasePayment(
    CasePayment(
      id: 'qa-case-pay1',
      caseId: 'qa-in',
      staffId: 'qa-n1',
      amountMinor: 6000,
      method: PaymentMethod.wallet,
      paidAt: at,
    ),
  );
  await repo.addCasePayment(
    CasePayment(
      id: 'qa-case-pay2',
      caseId: 'qa-out',
      staffId: 'qa-n1',
      amountMinor: 2000,
      method: PaymentMethod.cash,
      paidAt: at,
    ),
  );
  await repo.saveLabTest(
    const LabTest(id: 'qa-test', name: 'تحليل تجريبي', priceMinor: 10000),
  );
  await repo.addLabOrder(
    LabOrder(
      id: 'qa-order',
      patientName: 'مريض تجريبي',
      patientAge: 30,
      staffId: 'qa-n1',
      createdAt: at,
      items: const [
        LabOrderItem(
          testId: 'qa-test',
          name: 'تحليل تجريبي',
          priceMinor: 10000,
        ),
      ],
    ),
    initialPayment: LabPayment(
      id: 'qa-lab-pay1',
      orderId: 'qa-order',
      staffId: 'qa-n1',
      amountMinor: 2500,
      method: PaymentMethod.cash,
      createdAt: at,
    ),
  );
  await repo.addLabPayment(
    LabPayment(
      id: 'qa-lab-pay2',
      orderId: 'qa-order',
      staffId: 'qa-n1',
      amountMinor: 7500,
      method: PaymentMethod.wallet,
      createdAt: at,
    ),
  );
  await repo.setLabReceived('qa-order', 'qa-n1', received: true);
  // Later catalogue changes must leave the historical order at its old price.
  await repo.saveLabTest(
    const LabTest(
      id: 'qa-test',
      name: 'تحليل جديد',
      priceMinor: 12000,
      version: 1,
    ),
  );
  for (final entry in {
    CashKind.expense: 1000,
    CashKind.advance: 500,
    CashKind.award: 250,
    CashKind.externalAdvance: 300,
    CashKind.income: 200,
  }.entries) {
    await repo.addMovement(
      CashMovement(
        id: 'qa-${entry.key.name}',
        shiftId: '',
        staffId: 'qa-n1',
        kind: entry.key,
        amountMinor: entry.value,
        reason: 'QA only',
        createdAt: at,
        recipient: entry.key == CashKind.externalAdvance ? 'شخص تجريبي' : '',
      ),
    );
  }
  await repo.handoverDrawer(
    DrawerHandover(
      id: 'qa-hand1',
      fromStaffId: 'qa-n1',
      toStaffId: 'qa-n2',
      expectedMinor: repo.current.drawerBalance,
      countedMinor: repo.current.drawerBalance,
      at: at,
    ),
  );
  await repo.handoverDrawer(
    DrawerHandover(
      id: 'qa-hand2',
      fromStaffId: 'qa-n2',
      toStaffId: 'qa-n1',
      expectedMinor: repo.current.drawerBalance,
      countedMinor: repo.current.drawerBalance - 50,
      at: at.add(const Duration(hours: 1)),
      note: 'QA counted shortage',
    ),
  );
  await repo.updateRecord(ManagedRecordKind.caseRecord, 'qa-in', {
    'agreedTotal': 11000,
  }, 'QA price');
  await repo.addCase(
    CaseRecord(
      id: 'qa-delete',
      shiftId: '',
      staffId: 'qa-n1',
      title: 'إجراء تجريبي',
      procedureId: 'qa-p',
      supplies: const [],
      amountMinor: 0,
      agreedTotalMinor: 1000,
      payment: PaymentMethod.cash,
      location: CaseLocation.inside,
      createdAt: at,
    ),
  );
  await repo.deleteRecord(
    ManagedRecordKind.caseRecord,
    'qa-delete',
    'QA deletion',
  );
}
