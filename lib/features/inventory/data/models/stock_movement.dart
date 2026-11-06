class StockMovement {
  const StockMovement({
    required this.id,
    required this.stockItemId,
    required this.name,
    required this.delta,
    required this.kind,
    required this.at,
    this.caseId,
    this.staffId,
  });
  final String id, stockItemId, name, kind;
  final String? caseId, staffId;
  final int delta;
  final DateTime at;
  Map<String, dynamic> toJson() => {
    'id': id,
    'stockItemId': stockItemId,
    'name': name,
    'delta': delta,
    'kind': kind,
    'at': at.toIso8601String(),
    'caseId': caseId,
    'staffId': staffId,
  };
  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
    id: j['id'] as String,
    stockItemId: j['stockItemId'] as String,
    name: j['name'] as String,
    delta: j['delta'] as int,
    kind: j['kind'] as String,
    at: DateTime.parse(j['at'] as String),
    caseId: j['caseId'] as String?,
    staffId: j['staffId'] as String?,
  );
}
