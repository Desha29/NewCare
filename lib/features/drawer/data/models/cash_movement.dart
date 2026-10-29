enum CashKind { income, expense, advance, award, externalAdvance }

class CashMovement {
  const CashMovement({
    required this.id,
    required this.shiftId,
    required this.staffId,
    required this.kind,
    required this.amountMinor,
    required this.reason,
    required this.createdAt,
    this.recipient = '',
  });
  final String id, shiftId, staffId, reason, recipient;
  final CashKind kind;
  final int amountMinor;
  final DateTime createdAt;
  bool get isPersonOutgoing =>
      kind == CashKind.advance ||
      kind == CashKind.award ||
      kind == CashKind.externalAdvance ||
      (kind == CashKind.expense && recipient.trim().isNotEmpty);
  String get categoryKey => kind == CashKind.income
      ? 'income'
      : isPersonOutgoing
      ? 'personOutgoings'
      : 'centerExpense';
  String get purposeKey =>
      kind == CashKind.externalAdvance || kind == CashKind.advance
      ? 'advance'
      : kind == CashKind.award
      ? 'award'
      : isPersonOutgoing
      ? 'otherPersonOutgoing'
      : kind.name;
  bool get automaticReason =>
      kind == CashKind.advance ||
      kind == CashKind.externalAdvance ||
      kind == CashKind.award;
  int get signedMinor => kind == CashKind.income ? amountMinor : -amountMinor;
  Map<String, dynamic> toJson() => {
    'id': id,
    'shift': shiftId,
    'staff': staffId,
    'kind': kind.name,
    'amount': amountMinor,
    'reason': reason,
    'recipient': recipient,
    'created': createdAt.toIso8601String(),
  };
  factory CashMovement.fromJson(Map<String, dynamic> j) => CashMovement(
    id: j['id'] as String,
    shiftId: j['shift'] as String,
    staffId: j['staff'] as String,
    kind: CashKind.values.byName(j['kind'] as String),
    amountMinor: j['amount'] as int,
    reason: j['reason'] as String,
    recipient: j['recipient'] as String? ?? '',
    createdAt: DateTime.parse(j['created'] as String),
  );
}
