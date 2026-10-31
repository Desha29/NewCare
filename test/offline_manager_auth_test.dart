import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';
import 'package:newcare/features/auth/data/sources/password_verifier.dart';

class _Gateway implements ManagerGateway {
  Object? error;
  @override
  Future<ManagerIdentity> signIn(String username, String password) async {
    if (error != null) throw error!;
    if (password != 'valid-password') {
      throw const ManagerAuthException('wrongPassword');
    }
    return ManagerIdentity(
      id: 'manager-1',
      centerId: 'center-1',
      username: username,
      name: 'Manager',
      email: 'manager@example.invalid',
      manageAccounts: true,
      viewDiagnostics: true,
    );
  }

  @override
  Future<void> signOut() async {}
}

// Fast verifier for policy tests; the real KDF is verified separately below.
class _Verifier implements PasswordVerifier {
  @override
  Future<String> create(String password) async =>
      base64Encode(utf8.encode(password));
  @override
  Future<bool> matches(String password, String encoded) async =>
      base64Encode(utf8.encode(password)) == encoded;
}

void main() {
  late _Gateway gateway;
  late MemoryStringStore store;
  late DateTime now;
  late ManagerAuthRepository repo;
  setUp(() {
    gateway = _Gateway();
    store = MemoryStringStore();
    now = DateTime.utc(2026, 10, 30);
    repo = ManagerAuthRepository(
      centerId: 'center-1',
      gateway: gateway,
      store: store,
      verifier: _Verifier(),
      now: () => now,
    );
  });

  test(
    'offline requires a prior verified online login on this device',
    () async {
      gateway.error = const ManagerNetworkException();
      await expectLater(
        repo.signIn('mostafa', 'valid-password'),
        throwsA(
          isA<ManagerAuthException>().having(
            (e) => e.code,
            'code',
            'offlineLoginUnavailable',
          ),
        ),
      );
      gateway.error = null;
      expect(
        (await repo.signIn(' MOSTAFA ', 'valid-password')).mode,
        ManagerSessionMode.online,
      );
      gateway.error = const ManagerNetworkException();
      final reopened = ManagerAuthRepository(
        centerId: 'center-1',
        gateway: gateway,
        store: store,
        verifier: _Verifier(),
        now: () => now,
      );
      expect(
        (await reopened.signIn('mostafa', 'valid-password')).mode,
        ManagerSessionMode.offline,
      );
    },
  );

  test(
    'a server rejection invalidates cache and never falls back offline',
    () async {
      await repo.signIn('mostafa', 'valid-password');
      gateway.error = const ManagerAuthException('wrongPassword');
      await expectLater(
        repo.signIn('mostafa', 'valid-password'),
        throwsA(isA<ManagerAuthException>()),
      );
      gateway.error = const ManagerNetworkException();
      await expectLater(
        repo.signIn('mostafa', 'valid-password'),
        throwsA(
          isA<ManagerAuthException>().having(
            (e) => e.code,
            'code',
            'offlineLoginUnavailable',
          ),
        ),
      );
    },
  );

  test(
    'cache expires and clock rollback cannot extend offline access',
    () async {
      await repo.signIn('mostafa', 'valid-password');
      gateway.error = const ManagerNetworkException();
      now = now.subtract(const Duration(minutes: 1));
      await expectLater(
        repo.signIn('mostafa', 'valid-password'),
        throwsA(
          isA<ManagerAuthException>().having(
            (e) => e.code,
            'code',
            'offlineLoginExpired',
          ),
        ),
      );
      now = DateTime.utc(2026, 11, 6);
      await expectLater(
        repo.signIn('mostafa', 'valid-password'),
        throwsA(
          isA<ManagerAuthException>().having(
            (e) => e.code,
            'code',
            'offlineLoginExpired',
          ),
        ),
      );
    },
  );

  test(
    'five wrong offline passwords persist a lockout across restarts',
    () async {
      await repo.signIn('mostafa', 'valid-password');
      gateway.error = const ManagerNetworkException();
      for (var i = 0; i < 5; i++) {
        await expectLater(
          repo.signIn('mostafa', 'wrong'),
          throwsA(isA<ManagerAuthException>()),
        );
      }
      final reopened = ManagerAuthRepository(
        centerId: 'center-1',
        gateway: gateway,
        store: store,
        verifier: _Verifier(),
        now: () => now,
      );
      await expectLater(
        reopened.signIn('mostafa', 'valid-password'),
        throwsA(
          isA<ManagerAuthException>().having(
            (e) => e.code,
            'code',
            'offlineLoginLocked',
          ),
        ),
      );
      now = now.add(const Duration(minutes: 16));
      expect(
        (await reopened.signIn('mostafa', 'valid-password')).mode,
        ManagerSessionMode.offline,
      );
    },
  );

  test(
    'real password verifier uses salted PBKDF2 and rejects wrong passwords',
    () async {
      final verifier = Pbkdf2PasswordVerifier();
      final encoded = await verifier.create('correct horse battery');
      expect(encoded, isNot(contains('correct horse battery')));
      expect(await verifier.matches('correct horse battery', encoded), isTrue);
      expect(await verifier.matches('incorrect', encoded), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
