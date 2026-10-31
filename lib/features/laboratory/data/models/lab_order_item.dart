class LabOrderItem {
  const LabOrderItem({
    required this.testId,
    required this.name,
    required this.priceMinor,
  });

  final String testId;
  final String name;
  final int priceMinor;

  LabOrderItem copyWith({
    String? testId,
    String? name,
    int? priceMinor,
  }) =>
      LabOrderItem(
        testId: testId ?? this.testId,
        name: name ?? this.name,
        priceMinor: priceMinor ?? this.priceMinor,
      );

  Map<String, dynamic> toJson() => {
        'testId': testId,
        'name': name,
        'priceMinor': priceMinor,
      };

  factory LabOrderItem.fromJson(Map<String, dynamic> json) => LabOrderItem(
        testId: json['testId'] as String,
        name: json['name'] as String,
        priceMinor: (json['priceMinor'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabOrderItem &&
          runtimeType == other.runtimeType &&
          testId == other.testId &&
          name == other.name &&
          priceMinor == other.priceMinor;

  @override
  int get hashCode => Object.hash(testId, name, priceMinor);
}

