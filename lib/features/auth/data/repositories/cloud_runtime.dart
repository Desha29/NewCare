import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/string_store.dart';
import '../../../../core/storage/transactional_store.dart';
import '../models/manager_identity.dart';
import '../models/manager_username.dart';
import '../sources/encrypted_auth_storage.dart';
import '../sources/username_auth_configuration.dart';
import '../sources/center_binding_store.dart';
import '../sources/ephemeral_auth_client.dart';
import 'manager_auth_repository.dart';
import 'supabase_manager_gateway.dart';

/// Cloud mode is explicit and currently targets Windows protected storage.
/// Auth initialization never starts an operational data upload.
class CloudRuntime {
  CloudRuntime._(
    this.store,
    this.url,
    this.key,
    this.device,
    this.manager,
    this.centerId,
    this.localSetupComplete,
  );
  final StringStore store;
  final String url, key;
  final SupabaseClient device, manager;
  String? centerId;
  bool localSetupComplete;
  ManagerAuthRepository? _authentication;
  static Future<void>? _initialization;

  static Future<CloudRuntime?> open(StringStore store) async {
    const enabled = bool.fromEnvironment('NEWCARE_CLOUD');
    if (!enabled) return null;
    if (store is! TransactionalStore) {
      throw StateError('Cloud mode requires protected native storage');
    }
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (!url.startsWith('https://') ||
        key.isEmpty ||
        !key.startsWith('sb_publishable_')) {
      throw StateError('Invalid public cloud configuration');
    }
    _initialization ??= Supabase.initialize(
      url: url,
      publishableKey: key,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        localStorage: EncryptedAuthStorage(store),
      ),
    ).then<void>((_) {});
    await _initialization;
    final binding = await CenterBindingStore(store).load();
    return CloudRuntime._(
      store,
      url,
      key,
      Supabase.instance.client,
      createEphemeralAuthClient(url, key),
      binding.centerId,
      binding.localReady,
    );
  }

  SupabaseManagerGateway get gateway => SupabaseManagerGateway(
    centerId: centerId!,
    device: device,
    manager: manager,
    signupFactory: () => createEphemeralAuthClient(url, key),
    validateProvisioning: () =>
        UsernameAuthConfiguration.ensureReady(url: url, key: key),
  );
  ManagerAuthRepository get authentication =>
      _authentication ??= ManagerAuthRepository(
        centerId: centerId!,
        gateway: gateway,
        store: store,
      );

  Future<void> requestFirstManager(String username, String password) async {
    await UsernameAuthConfiguration.ensureReady(
      url: url,
      key: key,
      requireAnonymous: true,
    );
    // Unbound signups receive zero center privileges. Passwords never enter SQL.
    final response = await manager.auth.signUp(
      email: ManagerUsername.authAddress(username),
      password: password,
    );
    if (response.session == null) {
      throw const ManagerAuthException('emailConfirmationStillEnabled');
    }
  }

  Future<ManagerIdentity> activateFirstManager({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await manager.auth.signInWithPassword(
      email: ManagerUsername.authAddress(username),
      password: password,
    );
    final user = response.user;
    if (user == null || user.emailConfirmedAt == null) {
      throw const ManagerAuthException('emailConfirmationStillEnabled');
    }
    if (device.auth.currentUser == null) await device.auth.signInAnonymously();
    final deviceUser = device.auth.currentUser;
    if (deviceUser == null || !deviceUser.isAnonymous) {
      throw const ManagerAuthException('deviceEnrollmentRequired');
    }
    final existing = await manager
        .from('center_managers')
        .select('center_id')
        .eq('user_id', user.id)
        .eq('active', true)
        .maybeSingle();
    final id =
        existing?['center_id'] as String? ??
        await manager.rpc(
          'bootstrap_center',
          params: {
            'p_center_name': 'NewCare',
            'p_username': username.trim().toLowerCase(),
            'p_display_name': name.trim(),
            'p_contact_email': email.trim(),
            'p_device_user_id': deviceUser.id,
            'p_device_name': 'NewCare Windows',
          },
        ) as String;
    // An existing membership may be a retry after a response was lost. Confirm
    // this particular device was enrolled before saving the local binding.
    var enrollment = await device
        .from('center_devices')
        .select('center_id')
        .eq('auth_user_id', deviceUser.id)
        .eq('active', true)
        .maybeSingle();
    if (enrollment?['center_id'] != id) {
      await manager.rpc(
        'enroll_center_device',
        params: {
          'p_center_id': id,
          'p_device_user_id': deviceUser.id,
          'p_name': 'NewCare Windows',
        },
      );
      enrollment = await device
          .from('center_devices')
          .select('center_id')
          .eq('auth_user_id', deviceUser.id)
          .eq('active', true)
          .maybeSingle();
      if (enrollment?['center_id'] != id) {
        throw const ManagerAuthException('deviceEnrollmentRequired');
      }
    }
    if (centerId != null && centerId != id) {
      throw const ManagerAuthException('centerBindingMismatch');
    }
    centerId = id;
    final profile = await manager
        .from('manager_profiles')
        .select('username')
        .eq('user_id', user.id)
        .single();
    final session = await authentication.signIn(
      profile['username'] as String,
      password,
    );
    await CenterBindingStore(store).bindCloud(id);
    return session.identity;
  }

  Future<void> completeLocalSetup() async {
    await CenterBindingStore(store).completeLocalSetup(centerId!);
    localSetupComplete = true;
  }
}
