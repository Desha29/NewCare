import '../../../analytics/data/models/report_summary.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';

enum TransactionKind { casePayment, income, expense, advance, award }

/// Read model derived from source records, so a payment cannot be counted twice.
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.shiftId,
    required this.staffId,
    required this.description,
    required this.kind,
    required this.payment,
    required this.amountMinor,
    required this.at,
  });
  final String id, shiftId, staffId, description;
  final TransactionKind kind;
  final PaymentMethod payment;
  final int amountMinor;
  final DateTime at;
  bool get incoming =>
      kind == TransactionKind.casePayment || kind == TransactionKind.income;
  int get signedMinor => incoming ? amountMinor : -amountMinor;
  ManagedRecordKind get sourceKind => kind == TransactionKind.casePayment
      ? ManagedRecordKind.caseRecord
      : ManagedRecordKind.movement;

  static List<TransactionEntry> forRange(
    WorkspaceSnapshot data,
    DateTime start,
    DateTime end,
  ) {
    final summary = ReportSummary.forRange(data, start, end);
    return [
      for (final c in summary.cases)
        TransactionEntry(
          id: c.id,
          shiftId: c.shiftId,
          staffId: c.staffId,
          description: c.title,
          kind: TransactionKind.casePayment,
          payment: c.payment,
          amountMinor: c.amountMinor,
          at: c.createdAt,
        ),
      for (final m in summary.movements)
        TransactionEntry(
          id: m.id,
          shiftId: m.shiftId,
          staffId: m.staffId,
          description: m.reason,
          kind: switch (m.kind) {
            CashKind.income => TransactionKind.income,
            CashKind.expense => TransactionKind.expense,
            CashKind.advance => TransactionKind.advance,
            CashKind.award => TransactionKind.award,
          },
          payment: PaymentMethod.cash,
          amountMinor: m.amountMinor,
          at: m.createdAt,
        ),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }
}

class TransactionTotals {
  TransactionTotals(this.rows);
  final List<TransactionEntry> rows;
  int get cashIn => rows
      .where((r) => r.incoming && r.payment == PaymentMethod.cash)
      .fold(0, (s, r) => s + r.amountMinor);
  int get cashOut =>
      rows.where((r) => !r.incoming).fold(0, (s, r) => s + r.amountMinor);
  int get walletIn => rows
      .where((r) => r.payment == PaymentMethod.wallet)
      .fold(0, (s, r) => s + r.amountMinor);
  int get netCash => cashIn - cashOut;
  int amountFor(TransactionKind kind) =>
      rows.where((r) => r.kind == kind).fold(0, (s, r) => s + r.amountMinor);
}
