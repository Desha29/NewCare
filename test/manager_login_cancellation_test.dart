import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';
import 'package:newcare/features/auth/data/sources/password_verifier.dart';

class _Gateway implements ManagerGateway {
  final response = Completer<ManagerIdentity>();
  @override
  Future<ManagerIdentity> signIn(String username, String password) =>
      response.future;
  @override
  Future<void> signOut() async {}
}

class _Verifier implements PasswordVerifier {
  @override
  Future<String> create(String password) async => 'test-verifier';
  @override
  Future<bool> matches(String password, String encoded) async => false;
}

void main() {
  test(
    'late online login cannot unlock a manager area that was explicitly locked',
    () async {
      final store = MemoryStringStore(), gateway = _Gateway();
      final authentication = ManagerAuthRepository(
        centerId: 'c',
        gateway: gateway,
        store: store,
        verifier: _Verifier(),
      );
      final app = AppCubit(
        store,
        authentication: authentication,
        onManagerVerified: (_) async {},
      );
      final pending = app.signIn('manager', 'test-password');
      app.lock();
      gateway.response.complete(
        const ManagerIdentity(
          id: 'm',
          centerId: 'c',
          username: 'manager',
          name: 'Manager',
          email: 'contact@example.invalid',
          manageAccounts: true,
          viewDiagnostics: true,
        ),
      );
      expect(await pending, isFalse);
      expect(app.state.managerUnlocked, isFalse);
      await app.close();
    },
  );
}
