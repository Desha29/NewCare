enum CashKind { income, expense, advance }

class CashMovement {
  const CashMovement({
    required this.id,
    required this.shiftId,
    required this.staffId,
    required this.kind,
    required this.amountMinor,
    required this.reason,
    required this.createdAt,
  });
  final String id, shiftId, staffId, reason;
  final CashKind kind;
  final int amountMinor;
  final DateTime createdAt;
  int get signedMinor => kind == CashKind.income ? amountMinor : -amountMinor;
  Map<String, dynamic> toJson() => {
    'id': id,
    'shift': shiftId,
    'staff': staffId,
    'kind': kind.name,
    'amount': amountMinor,
    'reason': reason,
    'created': createdAt.toIso8601String(),
  };
  factory CashMovement.fromJson(Map<String, dynamic> j) => CashMovement(
    id: j['id'] as String,
    shiftId: j['shift'] as String,
    staffId: j['staff'] as String,
    kind: CashKind.values.byName(j['kind'] as String),
    amountMinor: j['amount'] as int,
    reason: j['reason'] as String,
    createdAt: DateTime.parse(j['created'] as String),
  );
}
