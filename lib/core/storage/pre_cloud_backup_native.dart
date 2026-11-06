import 'dart:io';

import 'package:path/path.dart' as p;

import 'sqlite_string_store.dart';
import 'string_store.dart';

Future<void> createPreCloudBackup(StringStore store) async {
  if (store is! SqliteStringStore) {
    throw StateError('Cloud linking requires protected native storage');
  }
  final root = Platform.environment['LOCALAPPDATA'];
  if (root == null || root.isEmpty) {
    throw StateError('Data directory unavailable');
  }
  final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
  await store.createBackup(
    p.join(root, 'NewCare', 'Backups', 'pre-cloud-link-$stamp.db'),
  );
}
