import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../../core/utils/center_clock.dart';

class ReportSummary {
  ReportSummary._(this.cases, this.movements, this.start, this.end);
  final List<CaseRecord> cases;
  final List<CashMovement> movements;
  final DateTime start, end;
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
    );
  }
  int get revenueMinor => cases.fold<int>(0, (s, c) => s + c.amountMinor);
  int get cashMinor => cases
      .where((c) => c.payment == PaymentMethod.cash)
      .fold<int>(0, (s, c) => s + c.amountMinor);
  int get walletMinor => revenueMinor - cashMinor;
  int get expenseMinor => movements
      .where((m) => m.kind == CashKind.expense)
      .fold<int>(0, (s, m) => s + m.amountMinor);
  int get advanceMinor => movements
      .where((m) => m.kind == CashKind.advance)
      .fold<int>(0, (s, m) => s + m.amountMinor);
}
