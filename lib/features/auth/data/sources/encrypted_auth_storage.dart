import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/string_store.dart';

/// Use only with the protected Windows store. Never persist manager sessions.
class EncryptedAuthStorage extends LocalStorage {
  const EncryptedAuthStorage(this.store);
  final StringStore store;
  static const key = 'newcare.device.auth.v1';
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => (await accessToken()) != null;
  @override
  Future<String?> accessToken() async {
    final value = await store.read(key);
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<void> persistSession(String persistSessionString) =>
      store.write(key, persistSessionString);
  @override
  Future<void> removePersistedSession() => store.write(key, '');
}
