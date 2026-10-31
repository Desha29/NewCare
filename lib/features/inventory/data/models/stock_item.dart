class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.active = true,
    this.version = 1,
  });
  final String id, name;
  final int quantity, version;
  final bool active;
  StockItem copyWith({
    String? name,
    int? quantity,
    bool? active,
    int? version,
  }) => StockItem(
    id: id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    active: active ?? this.active,
    version: version ?? this.version,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'active': active,
    'version': version,
  };
  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
    id: j['id'] as String,
    name: j['name'] as String,
    quantity: j['quantity'] as int,
    active: j['active'] as bool? ?? true,
    version: j['version'] as int? ?? 1,
  );
}
