import 'package:shared_preferences/shared_preferences.dart';

import 'string_store.dart';

class PreferencesStore implements StringStore {
  PreferencesStore(this.preferences);
  final SharedPreferences preferences;
  @override
  Future<String?> read(String key) async => preferences.getString(key);
  @override
  Future<void> write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('storageFailed');
    }
  }
}
