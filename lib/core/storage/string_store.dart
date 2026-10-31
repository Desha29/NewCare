abstract interface class StringStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

abstract interface class RemovableStringStore implements StringStore {
  Future<void> remove(String key);
}

class MemoryStringStore implements RemovableStringStore {
  final Map<String, String> _values = {};
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
