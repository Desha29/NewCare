import 'dart:convert';

class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    required this.at,
    this.detail = '',
  });
  final String id, action, detail;
  final DateTime at;
  String get reason {
    try {
      final value = jsonDecode(detail);
      return value is Map ? value['reason']?.toString() ?? '' : '';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'at': at.toIso8601String(),
    'detail': detail,
  };
  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
    id: j['id'] as String,
    action: j['action'] as String,
    at: DateTime.parse(j['at'] as String),
    detail: j['detail'] as String? ?? '',
  );
}
