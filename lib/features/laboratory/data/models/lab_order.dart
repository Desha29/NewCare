import 'lab_order_item.dart';

class LabOrder {
  const LabOrder({
    required this.id,
    required this.patientName,
    required this.patientAge,
    this.ageUnit = 'year',
    required this.staffId,
    required this.createdAt,
    this.items = const [],
    this.received = false,
    this.receivedAt,
    this.receivedBy,
    this.resultReason,
    this.version = 1,
  });

  final String id;
  final String patientName;
  final int patientAge;
  final String ageUnit;
  final String staffId;
  final DateTime createdAt;
  final List<LabOrderItem> items;
  final bool received;
  final DateTime? receivedAt;
  final String? receivedBy;
  final String? resultReason;
  final int version;

  int get totalMinor => items.fold<int>(0, (sum, i) => sum + i.priceMinor);

  LabOrder copyWith({
    String? id,
    String? patientName,
    int? patientAge,
    String? ageUnit,
    String? staffId,
    DateTime? createdAt,
    List<LabOrderItem>? items,
    bool? received,
    DateTime? receivedAt,
    String? receivedBy,
    String? resultReason,
    int? version,
  }) =>
      LabOrder(
        id: id ?? this.id,
        patientName: patientName ?? this.patientName,
        patientAge: patientAge ?? this.patientAge,
        ageUnit: ageUnit ?? this.ageUnit,
        staffId: staffId ?? this.staffId,
        createdAt: createdAt ?? this.createdAt,
        items: items ?? this.items,
        received: received ?? this.received,
        receivedAt: receivedAt ?? this.receivedAt,
        receivedBy: receivedBy ?? this.receivedBy,
        resultReason: resultReason ?? this.resultReason,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'patientAge': patientAge,
        'ageUnit': ageUnit,
        'staffId': staffId,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'received': received,
        if (receivedAt != null) 'receivedAt': receivedAt!.toIso8601String(),
        if (receivedBy != null) 'receivedBy': receivedBy,
        if (resultReason != null) 'resultReason': resultReason,
        'version': version,
      };

  factory LabOrder.fromJson(Map<String, dynamic> json) => LabOrder(
        id: json['id'] as String,
        patientName: json['patientName'] as String,
        patientAge: (json['patientAge'] as num).toInt(),
        ageUnit: json['ageUnit'] as String? ?? 'year',
        staffId: json['staffId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List? ?? [])
            .map((i) => LabOrderItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        received: json['received'] as bool? ?? false,
        receivedAt: json['receivedAt'] != null
            ? DateTime.parse(json['receivedAt'] as String)
            : null,
        receivedBy: json['receivedBy'] as String?,
        resultReason: json['resultReason'] as String?,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientName == other.patientName &&
          patientAge == other.patientAge &&
          ageUnit == other.ageUnit &&
          staffId == other.staffId &&
          createdAt == other.createdAt &&
          received == other.received &&
          receivedAt == other.receivedAt &&
          receivedBy == other.receivedBy &&
          resultReason == other.resultReason &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
        id,
        patientName,
        patientAge,
        ageUnit,
        staffId,
        createdAt,
        received,
        receivedAt,
        receivedBy,
        resultReason,
        version,
      );
}

