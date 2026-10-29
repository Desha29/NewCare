import '../../../analytics/data/models/report_summary.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';

enum TransactionKind {
  casePayment,
  income,
  expense,
  advance,
  award,
  externalAdvance,
}

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
    this.installment = false,
    this.personOutgoing = false,
    this.descriptionKey,
  });
  final String id, shiftId, staffId, description;
  final TransactionKind kind;
  final PaymentMethod payment;
  final int amountMinor;
  final DateTime at;
  final bool installment;
  final bool personOutgoing;
  final String? descriptionKey;
  static const categoryKeys = [
    'casePayment',
    'income',
    'centerExpense',
    'personOutgoings',
  ];
  String get categoryKey =>
      personOutgoing ||
          [
            TransactionKind.advance,
            TransactionKind.award,
            TransactionKind.externalAdvance,
          ].contains(kind)
      ? 'personOutgoings'
      : kind == TransactionKind.expense
      ? 'centerExpense'
      : kind.name;
  String get purposeKey => kind == TransactionKind.externalAdvance
      ? 'advance'
      : kind == TransactionKind.expense && personOutgoing
      ? 'otherPersonOutgoing'
      : kind.name;
  bool get incoming =>
      kind == TransactionKind.casePayment || kind == TransactionKind.income;
  int get signedMinor => incoming ? amountMinor : -amountMinor;
  ManagedRecordKind get sourceKind => installment
      ? ManagedRecordKind.caseReceipt
      : kind == TransactionKind.casePayment
      ? ManagedRecordKind.caseRecord
      : ManagedRecordKind.movement;

  static List<TransactionEntry> forRange(
    WorkspaceSnapshot data,
    DateTime start,
    DateTime end,
  ) {
    final summary = ReportSummary.forRange(data, start, end);
    return [
      for (final c in summary.cases.where((c) => c.amountMinor > 0))
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
      for (final p in summary.payments)
        TransactionEntry(
          id: p.id,
          shiftId: '',
          staffId: p.staffId,
          description:
              data.cases.where((c) => c.id == p.caseId).firstOrNull?.title ??
              '',
          kind: TransactionKind.casePayment,
          payment: p.method,
          amountMinor: p.amountMinor,
          at: p.paidAt,
          installment: true,
        ),
      for (final m in summary.movements)
        TransactionEntry(
          id: m.id,
          shiftId: m.shiftId,
          staffId: m.staffId,
          description: m.automaticReason
              ? m.recipient
              : m.recipient.isEmpty
              ? m.reason
              : '${m.reason} · ${m.recipient}',
          descriptionKey: m.automaticReason ? m.purposeKey : null,
          personOutgoing: m.isPersonOutgoing,
          kind: switch (m.kind) {
            CashKind.income => TransactionKind.income,
            CashKind.expense => TransactionKind.expense,
            CashKind.advance => TransactionKind.advance,
            CashKind.award => TransactionKind.award,
            CashKind.externalAdvance => TransactionKind.externalAdvance,
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
  int amountForCategory(String key) => rows
      .where((r) => r.categoryKey == key)
      .fold(0, (sum, r) => sum + r.amountMinor);
  int amountFor(TransactionKind kind) =>
      rows.where((r) => r.kind == kind).fold(0, (s, r) => s + r.amountMinor);
}
