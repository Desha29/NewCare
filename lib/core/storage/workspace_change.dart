import 'dart:convert';

/// Versioned changes for later server validation. Never upload a full client
/// snapshot as trusted database state or infer permissions from these fields.
Map<String, Object?> workspaceChange(
  Map<String, dynamic> before,
  Map<String, dynamic> after,
) {
  final collections = <String, Object?>{};
  final settings = <String, Object?>{};
  for (final entry in after.entries) {
    final old = before[entry.key];
    if (jsonEncode(old) == jsonEncode(entry.value)) continue;
    if (entry.value is List && old is List) {
      final nextRows = (entry.value as List).cast<Map<String, dynamic>>();
      final oldRows = old.cast<Map<String, dynamic>>();
      final previous = {for (final row in oldRows) row['id'] as String: row};
      final ids = nextRows.map((row) => row['id'] as String).toSet();
      collections[entry.key] = {
        'upsert': nextRows
            .where((row) => jsonEncode(previous[row['id']]) != jsonEncode(row))
            .toList(),
        'remove': previous.keys.where((id) => !ids.contains(id)).toList(),
      };
    } else {
      settings[entry.key] = entry.value;
    }
  }
  return {'version': 1, 'collections': collections, 'settings': settings};
}
