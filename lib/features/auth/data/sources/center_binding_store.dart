import '../../../../core/storage/string_store.dart';

class CenterBinding {
  const CenterBinding(this.centerId, this.localReady);
  final String? centerId;
  final bool localReady;
}

class CenterBindingStore {
  CenterBindingStore(this.store);
  final StringStore store;
  static const centerKey = 'newcare.center-id.v1';
  static const readyKey = 'newcare.center-local-ready.v1';
  Future<CenterBinding> load() async {
    final id = await store.read(centerKey);
    return CenterBinding(id, id != null && await store.read(readyKey) == id);
  }

  Future<void> bindCloud(String centerId) => store.write(centerKey, centerId);
  Future<void> completeLocalSetup(String centerId) async {
    if (await store.read(centerKey) != centerId) {
      throw StateError('Center binding changed');
    }
    await store.write(readyKey, centerId);
  }
}
