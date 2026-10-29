import 'case_record.dart';

/// A subsequent receipt belongs to its payment date, independently of the case date.
class CasePayment {
  const CasePayment({
    required this.id,
    required this.caseId,
    required this.staffId,
    required this.amountMinor,
    required this.method,
    required this.paidAt,
  });
  final String id, caseId, staffId;
  final int amountMinor;
  final PaymentMethod method;
  final DateTime paidAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'caseId': caseId,
    'staffId': staffId,
    'amount': amountMinor,
    'method': method.name,
    'paidAt': paidAt.toIso8601String(),
  };
  factory CasePayment.fromJson(Map<String, dynamic> j) => CasePayment(
    id: j['id'] as String,
    caseId: j['caseId'] as String,
    staffId: j['staffId'] as String,
    amountMinor: j['amount'] as int,
    method: PaymentMethod.values.byName(j['method'] as String),
    paidAt: DateTime.parse(j['paidAt'] as String),
  );
}
