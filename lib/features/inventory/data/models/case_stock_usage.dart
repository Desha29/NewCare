class CaseStockUsage {
  const CaseStockUsage({
    required this.stockItemId,
    required this.name,
    required this.quantity,
  });

  final String stockItemId, name;
  final int quantity;

  CaseStockUsage copyWith({
    String? stockItemId,
    String? name,
    int? quantity,
  }) =>
      CaseStockUsage(
        stockItemId: stockItemId ?? this.stockItemId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
    'stockItemId': stockItemId,
    'name': name,
    'quantity': quantity,
  };

  factory CaseStockUsage.fromJson(Map<String, dynamic> j) => CaseStockUsage(
    stockItemId: j['stockItemId'] as String,
    name: j['name'] as String,
    quantity: j['quantity'] as int,
  );
}
