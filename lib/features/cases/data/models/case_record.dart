import 'case_line_item.dart';

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
    this.lineItems = const [],
    this.agreedTotalMinor,
  });
  final String id, shiftId, staffId, title, procedureId, address, phone;
  final List<String> supplies;
  final int amountMinor;
  final int? agreedTotalMinor;
  int get invoiceMinor => agreedTotalMinor ?? totalMinor;
  final PaymentMethod payment;
  final CaseLocation location;
  final DateTime createdAt;
  final List<CaseLineItem> lineItems;
  List<String> get effectiveProcedureIds => lineItems.isEmpty
      ? [procedureId]
      : lineItems
            .where((i) => i.kind == CaseItemKind.procedure)
            .map((i) => i.catalogueId)
            .toList();
  int get totalMinor => lineItems.isEmpty
      ? amountMinor
      : lineItems.fold<int>(0, (sum, item) => sum + item.priceMinor);
  int revenueForProcedure(String id, {int? receiptMinor}) {
    final received = receiptMinor ?? amountMinor;
    if (lineItems.isEmpty) return procedureId == id ? received : 0;
    final price = lineItems
        .where((i) => i.kind == CaseItemKind.procedure && i.catalogueId == id)
        .fold<int>(0, (sum, i) => sum + i.priceMinor);
    return totalMinor == 0 ? 0 : received * price ~/ totalMinor;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shift': shiftId,
    'staff': staffId,
    'title': title,
    'procedure': procedureId,
    'supplies': supplies,
    'amount': amountMinor,
    'agreedTotal': agreedTotalMinor,
    'payment': payment.name,
    'location': location.name,
    'created': createdAt.toIso8601String(),
    'address': address,
    'phone': phone,
    'items': lineItems.map((i) => i.toJson()).toList(),
  };
  factory CaseRecord.fromJson(Map<String, dynamic> j) => CaseRecord(
    id: j['id'] as String,
    shiftId: j['shift'] as String,
    staffId: j['staff'] as String,
    title: j['title'] as String,
    procedureId: j['procedure'] as String,
    supplies: List<String>.from(j['supplies'] as List),
    amountMinor: j['amount'] as int,
    agreedTotalMinor: j['agreedTotal'] as int?,
    payment: PaymentMethod.values.byName(j['payment'] as String),
    location: CaseLocation.values.byName(j['location'] as String),
    createdAt: DateTime.parse(j['created'] as String),
    address: j['address'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    lineItems: (j['items'] as List? ?? [])
        .map((i) => CaseLineItem.fromJson(Map<String, dynamic>.from(i as Map)))
        .toList(),
  );
}
