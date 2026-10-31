import 'string_store.dart';

const legacyPreferenceKeys = [
  'newcare.workspace.v1',
  'newcare.locale',
  'newcare.managerPassword',
  'newcare.navigationLabels',
];

Future<void> migrateLegacyStore({
  required RemovableStringStore legacy,
  required StringStore target,
  required Future<void> Function(Map<String, String>) verifyProtectedBackup,
}) async {
  final migrated = <String, String>{};
  for (final key in legacyPreferenceKeys) {
    final original = await legacy.read(key);
    if (original == null) continue;
    final current = await target.read(key);
    if (current != null && current != original) {
      throw StateError('Conflicting legacy data requires recovery');
    }
    if (current == null) await target.write(key, original);
    if (await target.read(key) != original) {
      throw StateError('Migration verification failed');
    }
    migrated[key] = original;
  }
  if (migrated.isNotEmpty) {
    await verifyProtectedBackup(Map.unmodifiable(migrated));
    for (final key in migrated.keys) {
      await legacy.remove(key);
    }
  }
  await target.write('newcare.migration.preferences.v1', 'complete');
}
