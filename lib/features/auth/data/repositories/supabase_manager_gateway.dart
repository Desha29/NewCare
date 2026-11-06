import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/manager_identity.dart';
import '../models/manager_choice.dart';
import '../models/manager_username.dart';
import 'manager_gateway.dart';

/// Device and manager MUST be distinct clients. A manager login must never
/// replace the persistent device identity used by nurses.
class SupabaseManagerGateway
    implements ManagerAccountGateway, ManagerDirectoryGateway {
  SupabaseManagerGateway({
    required this.centerId,
    required this.device,
    required this.manager,
    this.signupFactory,
    this.validateProvisioning,
  }) {
    if (identical(device, manager)) {
      throw ArgumentError('Separate device and manager clients are required');
    }
  }
  final String centerId;
  final SupabaseClient device, manager;
  final SupabaseClient Function()? signupFactory;
  final Future<void> Function()? validateProvisioning;

  @override
  Future<List<ManagerChoice>> listManagers() async {
    final rows = await device.rpc(
      'list_center_login_managers',
      params: {'p_center_id': centerId},
    ) as List;
    return rows
        .map(
          (row) =>
              ManagerChoice.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<ManagerIdentity> signIn(String username, String password) async {
    try {
      final email = await device.rpc(
        'resolve_manager_login',
        params: {'p_center_id': centerId, 'p_username': username},
      );
      if (email is! String || email.isEmpty) {
        throw const ManagerAuthException('wrongPassword');
      }
      final response = await manager.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null || user.emailConfirmedAt == null) {
        throw const ManagerAuthException('wrongPassword');
      }
      final member = await manager
          .from('center_managers')
          .select('can_manage_accounts,can_view_diagnostics')
          .eq('center_id', centerId)
          .eq('user_id', user.id)
          .eq('active', true)
          .maybeSingle();
      final profile = await manager
          .from('manager_profiles')
          .select('username,display_name,contact_email')
          .eq('user_id', user.id)
          .maybeSingle();
      if (member == null ||
          profile == null ||
          profile['username'] != username) {
        await signOut();
        throw const ManagerAuthException('wrongPassword');
      }
      return ManagerIdentity(
        id: user.id,
        centerId: centerId,
        username: profile['username'] as String,
        name: profile['display_name'] as String,
        email: profile['contact_email'] as String,
        manageAccounts: member['can_manage_accounts'] as bool,
        viewDiagnostics: member['can_view_diagnostics'] as bool,
      );
    } on AuthRetryableFetchException {
      throw const ManagerNetworkException();
    } on http.ClientException {
      throw const ManagerNetworkException();
    } on TimeoutException {
      throw const ManagerNetworkException();
    } on AuthException {
      throw const ManagerAuthException('wrongPassword');
    } on PostgrestException {
      // A denial or a malformed server response is not an offline condition.
      throw const ManagerAuthException('managerRequired');
    }
  }

  @override
  Future<void> signOut() => manager.auth.signOut(scope: SignOutScope.local);

  @override
  Future<void> updateName(String name) => manager.rpc(
    'update_my_manager_name',
    params: {'p_display_name': name.trim()},
  );

  @override
  Future<void> requestEmailChange(String email) async {
    await manager.rpc(
      'update_my_manager_contact_email',
      params: {'p_email': email.trim()},
    );
  }

  @override
  Future<void> changePassword(
    String username,
    String current,
    String next,
  ) async {
    // Reauthentication protects password changes on an unattended center PC.
    await signIn(username, current);
    await manager.auth.updateUser(UserAttributes(password: next));
  }

  /// The isolated signup client must not persist or replace a manager session.
  /// An internal Auth identifier requires auto-confirm; no email is sent.
  Future<ManagerIdentity> _inviteManager({
    required String username,
    required String name,
    required String email,
    required String initialPassword,
    required SupabaseClient signupClient,
  }) async {
    if (identical(signupClient, device) || identical(signupClient, manager)) {
      throw ArgumentError('An isolated signup client is required');
    }
    final token = await manager.rpc(
      'create_manager_invitation',
      params: {
        'p_center_id': centerId,
        'p_username': username.trim().toLowerCase(),
        'p_display_name': name.trim(),
        'p_email': email.trim(),
      },
    ) as String;
    final response = await signupClient.auth.signUp(
      email: ManagerUsername.authAddress(username),
      password: initialPassword,
      data: {'newcare_invitation': token},
    );
    final user = response.user;
    if (user == null || response.session == null) {
      throw const ManagerAuthException('managerCreationFailed');
    }
    final staff = await manager
        .from('nursing_staff')
        .select('id,name')
        .eq('center_id', centerId)
        .eq('manager_user_id', user.id)
        .maybeSingle();
    if (staff == null) {
      throw const ManagerAuthException('managerCreationFailed');
    }
    return ManagerIdentity(
      id: user.id,
      centerId: centerId,
      username: ManagerUsername.normalize(username),
      name: staff['name'] as String,
      email: email.trim(),
      manageAccounts: false,
      viewDiagnostics: false,
    );
  }

  @override
  Future<ManagerIdentity> createManager({
    required String username,
    required String name,
    required String email,
    required String initialPassword,
  }) async {
    if (validateProvisioning == null) {
      throw const ManagerAuthException('emailConfirmationStillEnabled');
    }
    await validateProvisioning!();
    final signup = signupFactory?.call();
    if (signup == null) {
      throw const ManagerAuthException('onlineAccountChangeRequired');
    }
    try {
      return await _inviteManager(
        username: username,
        name: name,
        email: email,
        initialPassword: initialPassword,
        signupClient: signup,
      );
    } finally {
      await signup.dispose();
    }
  }
}
