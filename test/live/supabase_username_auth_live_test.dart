import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:newcare/core/storage/sqlite_string_store.dart';
import 'package:newcare/core/storage/storage_cipher.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/models/manager_username.dart';
import 'package:newcare/features/auth/data/repositories/manager_auth_repository.dart';
import 'package:newcare/features/auth/data/repositories/manager_gateway.dart';
import 'package:newcare/features/auth/data/repositories/supabase_manager_gateway.dart';
import 'package:newcare/features/auth/data/sources/username_auth_configuration.dart';
import 'package:newcare/features/auth/data/sources/ephemeral_auth_client.dart';

class _NetworkSwitch implements ManagerGateway {
  _NetworkSwitch(this.gateway);
  final ManagerGateway gateway;
  bool offline = false;
  @override
  Future<ManagerIdentity> signIn(String username, String password) {
    if (offline) throw const ManagerNetworkException();
    return gateway.signIn(username, password);
  }

  @override
  Future<void> signOut() => gateway.signOut();
}

void main() {
  const enabled = bool.fromEnvironment('NEWCARE_LIVE_AUTH_TESTS');
  test(
    'live username accounts, device isolation, profile, password and offline cache',
    () async {
      const url = String.fromEnvironment('SUPABASE_URL');
      const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
      expect(url, 'https://gcwwtsoavmbeaclkigus.supabase.co');
      expect(key.startsWith('sb_publishable_'), isTrue);
      final record = File('test-results/live-auth-owned-records.json');
      if (await record.exists()) {
        throw StateError('Clean up the prior live test before rerunning');
      }
      await record.parent.create(recursive: true);
      final random = Random.secure();
      String secret() =>
          base64UrlEncode(List<int>.generate(36, (_) => random.nextInt(256)));
      final suffix = List<int>.generate(
        6,
        (_) => random.nextInt(256),
      ).map((n) => n.toRadixString(16).padLeft(2, '0')).join();
      final username = 'ncqa_a_$suffix', usernameB = 'ncqa_b_$suffix';
      final password = secret(), passwordB = secret(), nextPassword = secret();
      final device = createEphemeralAuthClient(url, key),
          manager = createEphemeralAuthClient(url, key),
          managerB = createEphemeralAuthClient(url, key);
      final owned = <String, Object?>{
        'testMarker': 'newcare-disposable-auth-test',
        'userIds': <String>[],
        'centerId': null,
        'usernames': [username, usernameB],
      };
      Future<void> remember() async =>
          record.writeAsString(jsonEncode(owned), flush: true);
      await remember();
      final directory = await Directory.systemTemp.createTemp(
        'newcare-live-auth-',
      );
      SqliteStringStore? store;
      try {
        await UsernameAuthConfiguration.ensureReady(
          url: url,
          key: key,
          requireAnonymous: true,
        );
        final anonymous = await device.auth.signInAnonymously();
        (owned['userIds'] as List<String>).add(anonymous.user!.id);
        await remember();
        final response = await manager.auth.signUp(
          email: ManagerUsername.authAddress(username),
          password: password,
        );
        expect(response.session != null, isTrue);
        (owned['userIds'] as List<String>).add(response.user!.id);
        await remember();
        final center = await manager.rpc(
          'bootstrap_center',
          params: {
            'p_center_name': 'NewCare disposable auth test',
            'p_username': username,
            'p_display_name': 'Disposable manager A',
            'p_contact_email': 'qa@example.invalid',
            'p_device_user_id': anonymous.user!.id,
            'p_device_name': 'Disposable test device',
          },
        ) as String;
        owned['centerId'] = center;
        await remember();
        final gateway = SupabaseManagerGateway(
          centerId: center,
          device: device,
          manager: manager,
          signupFactory: () => createEphemeralAuthClient(url, key),
          validateProvisioning: () =>
              UsernameAuthConfiguration.ensureReady(url: url, key: key),
        );
        final identity = await gateway.signIn(username, password);
        expect(identity.id, response.user!.id);
        expect(identity.email, 'qa@example.invalid');
        expect(identity.manageAccounts, isTrue);
        expect(
          await device
              .from('nursing_payroll')
              .select('staff_id')
              .eq('center_id', center),
          isEmpty,
        );
        expect(
          await device.from('manager_profiles').select('user_id'),
          isEmpty,
        );
        await expectLater(
          device.rpc(
            'create_manager_invitation',
            params: {
              'p_center_id': center,
              'p_username': 'denied_$suffix',
              'p_display_name': 'Denied',
              'p_email': 'denied@example.invalid',
            },
          ),
          throwsA(
            isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
          ),
        );
        final created = await gateway.createManager(
          username: usernameB,
          name: 'Disposable manager B',
          email: 'qa-b@example.invalid',
          initialPassword: passwordB,
        );
        (owned['userIds'] as List<String>).add(created.id);
        await remember();
        final second = SupabaseManagerGateway(
          centerId: center,
          device: device,
          manager: managerB,
        );
        final secondIdentity = await second.signIn(usernameB, passwordB);
        expect(secondIdentity.manageAccounts, isFalse);
        await expectLater(
          managerB.rpc(
            'create_manager_invitation',
            params: {
              'p_center_id': center,
              'p_username': 'denied_$suffix',
              'p_display_name': 'Denied',
              'p_email': 'denied@example.invalid',
            },
          ),
          throwsA(
            isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
          ),
        );
        await second.updateName('Disposable manager B updated');
        await second.requestEmailChange('changed-contact@example.invalid');
        final updated = await second.signIn(usernameB, passwordB);
        expect(updated.name, 'Disposable manager B updated');
        expect(updated.email, 'changed-contact@example.invalid');
        expect(
          managerB.auth.currentUser!.email,
          ManagerUsername.authAddress(usernameB),
        );
        await gateway.changePassword(username, password, nextPassword);
        await expectLater(
          gateway.signIn(username, password),
          throwsA(isA<ManagerAuthException>()),
        );
        expect((await gateway.signIn(username, nextPassword)).id, identity.id);
        store = await SqliteStringStore.open(
          path: '${directory.path}/data.db',
          cipher: StorageCipher(
            List<int>.generate(32, (_) => random.nextInt(256)),
          ),
        );
        final transport = _NetworkSwitch(gateway);
        final authentication = ManagerAuthRepository(
          centerId: center,
          gateway: transport,
          store: store,
        );
        expect(
          (await authentication.signIn(username, nextPassword)).mode,
          ManagerSessionMode.online,
        );
        transport.offline = true;
        expect(
          (await authentication.signIn(username, nextPassword)).mode,
          ManagerSessionMode.offline,
        );
        await expectLater(
          authentication.changePassword(nextPassword, secret()),
          throwsA(
            isA<ManagerAuthException>().having(
              (e) => e.code,
              'code',
              'onlineAccountChangeRequired',
            ),
          ),
        );
      } finally {
        await store?.close();
        await directory.delete(recursive: true);
        for (final client in [managerB, manager, device]) {
          try {
            await client.auth.signOut(scope: SignOutScope.local);
          } catch (_) {}
          await client.dispose();
        }
        await remember();
        // A trusted developer uses Supabase MCP to delete ONLY these recorded test
        // IDs after the run. Never put a service-role key in the test or Flutter.
      }
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
