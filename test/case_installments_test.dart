import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/data/models/case_payment.dart';
import 'package:newcare/features/catalogue/data/models/procedure.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';
import 'package:newcare/features/transactions/data/models/transaction_entry.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';

void main() {
  test('shiftless cases retain negotiated price, partial receipts and payment dates', () async {
    final store = MemoryStringStore();
    final repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await repo.addStaff(const NursingMember(id: 'n', name: 'محمود'));
    await repo.addProcedure(
      const Procedure(
        id: 'p',
        nameAr: 'غيار',
        nameEn: 'Dressing',
        priceMinor: 25000,
      ),
    );
    final day = DateTime(2026, 10, 20, 12);
    final record = CaseRecord(
      id: 'c',
      shiftId: '',
      staffId: 'n',
      title: 'غيار',
      procedureId: 'p',
      supplies: [],
      amountMinor: 10000,
      agreedTotalMinor: 20000,
      payment: PaymentMethod.cash,
      location: CaseLocation.inside,
      createdAt: day,
    );
    await repo.addCase(record);
    expect(repo.current.shifts, isEmpty);
    expect(repo.current.remainingFor(record), 10000);
    final later = CasePayment(
      id: 'pay1',
      caseId: 'c',
      staffId: 'n',
      amountMinor: 5000,
      method: PaymentMethod.wallet,
      paidAt: DateTime(2026, 10, 21, 12),
    );
    await repo.addCasePayment(later);
    await repo.addCasePayment(later);
    expect(repo.current.payments, hasLength(1));
    expect(repo.current.drawerBalance, 10000);
    expect(repo.current.remainingFor(record), 5000);
    await expectLater(
      repo.addCasePayment(
        CasePayment(
          id: 'bad',
          caseId: 'c',
          staffId: 'n',
          amountMinor: 6000,
          method: PaymentMethod.cash,
          paidAt: day,
        ),
      ),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.addCasePayment(
      CasePayment(
        id: 'pay2',
        caseId: 'c',
        staffId: 'n',
        amountMinor: 5000,
        method: PaymentMethod.cash,
        paidAt: DateTime(2026, 10, 22, 12),
      ),
    );
    expect(repo.current.drawerBalance, 15000);
    expect(repo.current.remainingFor(record), 0);
    final receipts = TransactionEntry.forRange(
      repo.current,
      DateTime(2026, 10, 21),
      DateTime(2026, 10, 21),
    );
    expect(receipts, hasLength(1));
    expect(receipts.single.amountMinor, 5000);
    final restored = LocalWorkspaceRepository(store, seedDemo: false);
    await restored.initialize();
    expect(restored.current.payments, hasLength(2));
    expect(restored.current.remainingFor(restored.current.cases.single), 0);
    await repo.updateRecord(ManagedRecordKind.caseRecord, 'c', {
      'agreedTotal': 25000,
    }, 'casePriceUpdated');
    expect(repo.current.drawerBalance, 15000);
    expect(repo.current.remainingFor(repo.current.cases.single), 5000);
    expect(repo.current.cases.single.amountMinor, 10000);
    expect(repo.current.payments, hasLength(2));
    await expectLater(
      repo.updateRecord(ManagedRecordKind.caseRecord, 'c', {
        'agreedTotal': 19000,
      }, 'casePriceUpdated'),
      throwsA(isA<WorkspaceException>()),
    );
    await repo.dispose();
    await restored.dispose();
  });
}
