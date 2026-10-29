import '../../../cases/data/models/case_payment.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../../core/utils/center_clock.dart';

class ReportSummary {
  ReportSummary._(
    this.cases,
    this.movements,
    this.start,
    this.end,
    this.payments,
  );
  final List<CaseRecord> cases;
  final List<CashMovement> movements;
  final DateTime start, end;
  final List<CasePayment> payments;
  factory ReportSummary.forRange(
    WorkspaceSnapshot data,
    DateTime start,
    DateTime end,
  ) {
    final first = CenterClock.dayStart(start),
        after = CenterClock.dayAfter(end);
    bool includes(DateTime date) =>
        !date.isBefore(first) && date.isBefore(after);
    return ReportSummary._(
      List.unmodifiable(data.cases.where((c) => includes(c.createdAt))),
      List.unmodifiable(data.movements.where((m) => includes(m.createdAt))),
      first,
      after,
      List.unmodifiable(data.payments.where((p) => includes(p.paidAt))),
    );
  }
  int get revenueMinor =>
      cases.fold<int>(0, (s, c) => s + c.amountMinor) +
      payments.fold<int>(0, (s, p) => s + p.amountMinor);
  int get cashMinor =>
      cases
          .where((c) => c.payment == PaymentMethod.cash)
          .fold<int>(0, (s, c) => s + c.amountMinor) +
      payments
          .where((p) => p.method == PaymentMethod.cash)
          .fold<int>(0, (s, p) => s + p.amountMinor);
  int get walletMinor => revenueMinor - cashMinor;
  int procedureReceipts(WorkspaceSnapshot data, String procedureId) =>
      cases.fold<int>(0, (sum, c) => sum + c.revenueForProcedure(procedureId)) +
      payments.fold<int>(
        0,
        (sum, p) =>
            sum +
            (data.cases
                    .where((c) => c.id == p.caseId)
                    .firstOrNull
                    ?.revenueForProcedure(
                      procedureId,
                      receiptMinor: p.amountMinor,
                    ) ??
                0),
      );
  int get expenseMinor => movements
      .where((m) => m.kind == CashKind.expense || m.kind == CashKind.award)
      .fold<int>(0, (s, m) => s + m.amountMinor);
  int get advanceMinor => movements
      .where((m) => m.kind == CashKind.advance)
      .fold<int>(0, (s, m) => s + m.amountMinor);
  int get awardMinor => movements
      .where((m) => m.kind == CashKind.award)
      .fold<int>(0, (s, m) => s + m.amountMinor);
}
