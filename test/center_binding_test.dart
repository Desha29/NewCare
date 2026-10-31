import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/sources/center_binding_store.dart';

void main() {
  test(
    'cloud binding alone never skips unfinished local setup after restart',
    () async {
      final store = MemoryStringStore();
      final binding = CenterBindingStore(store);
      await binding.bindCloud('center-1');
      final recovered = await CenterBindingStore(store).load();
      expect(recovered.centerId, 'center-1');
      expect(recovered.localReady, isFalse);
      await binding.completeLocalSetup('center-1');
      expect((await binding.load()).localReady, isTrue);
      await binding.bindCloud('center-2');
      expect((await binding.load()).localReady, isFalse);
    },
  );
}
