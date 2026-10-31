import 'dart:convert';

import 'package:cryptography/cryptography.dart';

enum ReconciliationStatus {
  unconfigured,
  unavailable,
  pending,
  different,
  matched,
}

/// Both manifests must be generated from the same authorized projection and
/// committed server revision. Counts alone never prove equivalence.
class DataManifest {
  const DataManifest({
    required this.scope,
    required this.revision,
    required this.contentHash,
    required this.counts,
  });
  final String scope, contentHash;
  final int revision;
  final Map<String, int> counts;

  static Future<DataManifest> create({
    required String scope,
    required int revision,
    required Map<String, Object?> data,
    required Map<String, int> counts,
  }) async {
    final canonical = jsonEncode(_canonical(data));
    final hash = await Sha256().hash(utf8.encode(canonical));
    return DataManifest(
      scope: scope,
      revision: revision,
      contentHash: base64Encode(hash.bytes),
      counts: Map.unmodifiable(counts),
    );
  }
}

Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) {
    final rows = value.map(_canonical).toList();
    // Record collections have stable IDs. Other arrays preserve semantic order.
    if (rows.isNotEmpty && rows.every((r) => r is Map && r['id'] is String)) {
      rows.sort(
        (a, b) =>
            ((a as Map)['id'] as String).compareTo((b as Map)['id'] as String),
      );
    }
    return rows;
  }
  return value;
}

ReconciliationStatus reconcile({
  required bool configured,
  required bool authenticated,
  required bool online,
  required int pendingCount,
  required int conflictCount,
  DataManifest? local,
  DataManifest? remote,
}) {
  if (!configured) return ReconciliationStatus.unconfigured;
  if (!authenticated || !online || local == null || remote == null) {
    return ReconciliationStatus.unavailable;
  }
  if (pendingCount != 0 || conflictCount != 0) {
    return ReconciliationStatus.pending;
  }
  final sameCounts =
      local.counts.length == remote.counts.length &&
      local.counts.entries.every((e) => remote.counts[e.key] == e.value);
  if (local.scope.isEmpty ||
      local.scope != remote.scope ||
      local.revision != remote.revision ||
      !sameCounts ||
      local.contentHash.isEmpty ||
      local.contentHash != remote.contentHash) {
    return ReconciliationStatus.different;
  }
  return ReconciliationStatus.matched;
}
