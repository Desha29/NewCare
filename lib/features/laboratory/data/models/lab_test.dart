class LabTest {
  const LabTest({
    required this.id,
    required this.name,
    required this.priceMinor,
    this.active = true,
    this.version = 1,
  });

  final String id;
  final String name;
  final int priceMinor;
  final bool active;
  final int version;

  LabTest copyWith({
    String? id,
    String? name,
    int? priceMinor,
    bool? active,
    int? version,
  }) =>
      LabTest(
        id: id ?? this.id,
        name: name ?? this.name,
        priceMinor: priceMinor ?? this.priceMinor,
        active: active ?? this.active,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priceMinor': priceMinor,
        'active': active,
        'version': version,
      };

  factory LabTest.fromJson(Map<String, dynamic> json) => LabTest(
        id: json['id'] as String,
        name: json['name'] as String,
        priceMinor: (json['priceMinor'] as num).toInt(),
        active: json['active'] as bool? ?? true,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabTest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          priceMinor == other.priceMinor &&
          active == other.active &&
          version == other.version;

  @override
  int get hashCode => Object.hash(id, name, priceMinor, active, version);
}

