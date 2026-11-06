import 'string_store.dart';

Future<void> createPreCloudBackup(StringStore store) async {
  throw UnsupportedError('Cloud linking requires protected native storage');
}
