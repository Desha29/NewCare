import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_choice.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';

class DirectoryGateway implements ManagerGateway, ManagerDirectoryGateway {
  bool offline = false;
  @override
  Future<List<ManagerChoice>> listManagers() async {
    if (offline) throw const ManagerNetworkException();
    return const [ManagerChoice(id: 'm', username: 'mostafa', name: 'Mostafa')];
  }

  @override
  Future<ManagerIdentity> signIn(String username, String password) async =>
      throw const ManagerAuthException('wrongPassword');
  @override
  Future<void> signOut() async {}
}

void main() {
  test(
    'manager cards cache names and usernames per center without granting login',
    () async {
      final store = MemoryStringStore();
      final gateway = DirectoryGateway();
      final auth = ManagerAuthRepository(
        centerId: 'center-a',
        gateway: gateway,
        store: store,
      );
      expect((await auth.listManagers()).single.username, 'mostafa');
      gateway.offline = true;
      expect((await auth.listManagers()).single.name, 'Mostafa');
      expect(auth.currentSession, isNull);
      await expectLater(
        auth.signIn('mostafa', 'bad-password'),
        throwsA(isA<ManagerAuthException>()),
      );
      final another = ManagerAuthRepository(
        centerId: 'center-b',
        gateway: gateway,
        store: store,
      );
      expect(await another.listManagers(), isEmpty);
    },
  );
}
