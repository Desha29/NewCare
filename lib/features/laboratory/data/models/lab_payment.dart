import '../../../cases/data/models/case_record.dart';

class LabPayment {
  const LabPayment({
    required this.id,
    required this.orderId,
    required this.amountMinor,
    required this.method,
    required this.staffId,
    required this.createdAt,
    this.version = 1,
  });

  final String id;
  final String orderId;
  final int amountMinor;
  final PaymentMethod method;
  final String staffId;
  final DateTime createdAt;
  final int version;

  LabPayment copyWith({
    String? id,
    String? orderId,
    int? amountMinor,
    PaymentMethod? method,
    String? staffId,
    DateTime? createdAt,
    int? version,
  }) =>
      LabPayment(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        amountMinor: amountMinor ?? this.amountMinor,
        method: method ?? this.method,
        staffId: staffId ?? this.staffId,
        createdAt: createdAt ?? this.createdAt,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'amountMinor': amountMinor,
        'method': method.name,
        'staffId': staffId,
        'createdAt': createdAt.toIso8601String(),
        'version': version,
      };

  factory LabPayment.fromJson(Map<String, dynamic> json) => LabPayment(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        amountMinor: (json['amountMinor'] as num).toInt(),
        method: PaymentMethod.values.byName(json['method'] as String),
        staffId: json['staffId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        version: (json['version'] as num?)?.toInt() ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabPayment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderId == other.orderId &&
          amountMinor == other.amountMinor &&
          method == other.method &&
          staffId == other.staffId &&
          createdAt == other.createdAt &&
          version == other.version;

  @override
  int get hashCode =>
      Object.hash(id, orderId, amountMinor, method, staffId, createdAt, version);
}

