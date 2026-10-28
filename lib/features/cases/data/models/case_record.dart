enum CaseLocation { inside, outside }

enum PaymentMethod { cash, wallet }

class CaseRecord {
  const CaseRecord({
    required this.id,
    required this.shiftId,
    required this.staffId,
    required this.title,
    required this.procedureId,
    required this.supplies,
    required this.amountMinor,
    required this.payment,
    required this.location,
    required this.createdAt,
    this.address = '',
    this.phone = '',
  });
  final String id, shiftId, staffId, title, procedureId, address, phone;
  final List<String> supplies;
  final int amountMinor;
  final PaymentMethod payment;
  final CaseLocation location;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'shift': shiftId,
    'staff': staffId,
    'title': title,
    'procedure': procedureId,
    'supplies': supplies,
    'amount': amountMinor,
    'payment': payment.name,
    'location': location.name,
    'created': createdAt.toIso8601String(),
    'address': address,
    'phone': phone,
  };
  factory CaseRecord.fromJson(Map<String, dynamic> j) => CaseRecord(
    id: j['id'] as String,
    shiftId: j['shift'] as String,
    staffId: j['staff'] as String,
    title: j['title'] as String,
    procedureId: j['procedure'] as String,
    supplies: List<String>.from(j['supplies'] as List),
    amountMinor: j['amount'] as int,
    payment: PaymentMethod.values.byName(j['payment'] as String),
    location: CaseLocation.values.byName(j['location'] as String),
    createdAt: DateTime.parse(j['created'] as String),
    address: j['address'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
  );
}
