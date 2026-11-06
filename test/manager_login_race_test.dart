import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';

class DelayedGateway implements ManagerGateway {
  final first = Completer<ManagerIdentity>();
  final calls = <String>[];
  @override
  Future<ManagerIdentity> signIn(String username, String password) async {
    calls.add(username);
    if (username == 'manager_a') return first.future;
    throw const ManagerAuthException('wrongPassword');
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets(
    'a deadline cannot release serialization while an auth side effect is alive',
    (tester) async {
      final gateway = DelayedGateway();
      final auth = ManagerAuthRepository(
        centerId: 'c',
        gateway: gateway,
        store: MemoryStringStore(),
      );
      final first = auth
          .signIn('manager_a', 'password')
          .then<void>((_) {}, onError: (Object _) {});
      final second = auth
          .signIn('manager_b', 'password')
          .then<void>((_) {}, onError: (Object _) {});
      await tester.pump();
      await tester.pump(const Duration(seconds: 16));
      expect(gateway.calls, ['manager_a']);
      gateway.first.completeError(const ManagerNetworkException());
      await first;
      await second;
      expect(gateway.calls, ['manager_a', 'manager_b']);
    },
  );
}
