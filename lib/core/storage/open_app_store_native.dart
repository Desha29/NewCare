import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

import 'preferences_store.dart';
import 'legacy_store_migration.dart';
import 'sqlite_string_store.dart';
import 'storage_cipher.dart';
import 'string_store.dart';

Future<StringStore> openAppStore(PreferencesStore legacy) async {
  // Windows is the current supported production target. Other previews retain
  // their existing adapter until their protected storage paths are configured.
  if (!Platform.isWindows) return legacy;
  final root = Platform.environment['LOCALAPPDATA'];
  if (root == null || root.isEmpty) {
    throw StateError('Data directory unavailable');
  }
  final path = p.join(root, 'NewCare', 'Data', 'newcare.db');
  const secure = FlutterSecureStorage();
  const keyName = 'newcare.database.payload-key.v1';
  var encoded = await secure.read(key: keyName);
  if (encoded == null) {
    if (await File(path).exists()) {
      throw StateError('Database key unavailable; recovery is required');
    }
    final random = Random.secure();
    encoded = base64Encode(List<int>.generate(32, (_) => random.nextInt(256)));
    await secure.write(key: keyName, value: encoded);
    if (await secure.read(key: keyName) != encoded) {
      throw StateError('Unable to protect the database key');
    }
  }
  final cipher = StorageCipher(base64Decode(encoded));
  final store = await SqliteStringStore.open(path: path, cipher: cipher);
  try {
    await migrateLegacyStore(
      legacy: legacy,
      target: store,
      verifyProtectedBackup: (values) async {
        final backupPath = p.join(
          root,
          'NewCare',
          'Backups',
          'preferences-migration-v1.db',
        );
        if (!await File(backupPath).exists()) {
          await store.createBackup(backupPath);
        }
        final backup = await SqliteStringStore.open(
          path: backupPath,
          cipher: cipher,
        );
        try {
          for (final entry in values.entries) {
            if (await backup.read(entry.key) != entry.value) {
              throw StateError(
                'Protected migration backup could not be verified',
              );
            }
          }
        } finally {
          await backup.close();
        }
      },
    );
    return store;
  } catch (_) {
    await store.close();
    rethrow;
  }
}
