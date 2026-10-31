import 'dart:convert';

import '../../../../core/storage/string_store.dart';
import '../models/manager_identity.dart';
import '../sources/password_verifier.dart';
import 'manager_gateway.dart';

enum ManagerSessionMode { online, offline }

class ManagerSession {
  const ManagerSession(this.identity, this.mode, {this.expiresAt});
  final ManagerIdentity identity;
  final ManagerSessionMode mode;
  final DateTime? expiresAt;
}

/// A cached login never manufactures a Supabase session. Cloud commands still
/// require online Auth and fresh server-side permissions.
class ManagerAuthRepository {
  ManagerAuthRepository({
    required this.centerId,
    required this.gateway,
    required this.store,
    PasswordVerifier? verifier,
    DateTime Function()? now,
  }) : verifier = verifier ?? Pbkdf2PasswordVerifier(),
       now = now ?? DateTime.now;
  final String centerId;
  final ManagerGateway gateway;
  final StringStore store;
  final PasswordVerifier verifier;
  final DateTime Function() now;
  static const offlineLifetime = Duration(days: 7);
  static const lockout = Duration(minutes: 15);
  Future<void> _tail = Future.value();
  ManagerSession? currentSession;

  String _key(String username) =>
      'newcare.offline-manager.v1.$centerId.$username';

  Future<ManagerSession> signIn(String username, String password) {
    final result = _tail.then(
      (_) => _signIn(username.trim().toLowerCase(), password),
    );
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<ManagerSession> _signIn(String username, String password) async {
    currentSession = null;
    if (!RegExp(r'^[a-z0-9_]{3,32}$').hasMatch(username) || password.isEmpty) {
      throw const ManagerAuthException('wrongPassword');
    }
    try {
      final identity = await gateway.signIn(username, password);
      if (identity.centerId != centerId || identity.username != username) {
        await gateway.signOut();
        throw const ManagerAuthException('wrongPassword');
      }
      final stamp = now().toUtc();
      await store.write(
        _key(username),
        jsonEncode({
          'identity': identity.toJson(),
          'verifier': await verifier.create(password),
          'verifiedAt': stamp.toIso8601String(),
          'lastSeen': stamp.toIso8601String(),
          'failures': 0,
        }),
      );
      return currentSession = ManagerSession(
        identity,
        ManagerSessionMode.online,
      );
    } on ManagerNetworkException {
      return _offline(username, password);
    } on ManagerAuthException {
      // An online rejection must never fall back to a previously valid password.
      await store.write(_key(username), '');
      rethrow;
    }
  }

  Future<ManagerSession> _offline(String username, String password) async {
    final raw = await store.read(_key(username));
    if (raw == null || raw.isEmpty) {
      throw const ManagerAuthException('offlineLoginUnavailable');
    }
    final cached = jsonDecode(raw) as Map<String, dynamic>;
    final stamp = now().toUtc();
    final verified = DateTime.parse(cached['verifiedAt'] as String).toUtc();
    final lastSeen = DateTime.parse(cached['lastSeen'] as String).toUtc();
    if (stamp.isBefore(lastSeen) ||
        stamp.isBefore(verified) ||
        stamp.difference(verified) >= offlineLifetime) {
      throw const ManagerAuthException('offlineLoginExpired');
    }
    final blocked = DateTime.tryParse(cached['blockedUntil'] as String? ?? '');
    if (blocked != null && stamp.isBefore(blocked)) {
      throw const ManagerAuthException('offlineLoginLocked');
    }
    final valid = await verifier.matches(
      password,
      cached['verifier'] as String,
    );
    cached['lastSeen'] = stamp.toIso8601String();
    if (!valid) {
      final failures = (cached['failures'] as int? ?? 0) + 1;
      cached['failures'] = failures;
      if (failures >= 5) {
        cached['blockedUntil'] = stamp.add(lockout).toIso8601String();
        cached['failures'] = 0;
      }
      await store.write(_key(username), jsonEncode(cached));
      throw const ManagerAuthException('wrongPassword');
    }
    final identity = ManagerIdentity.fromJson(
      Map<String, dynamic>.from(cached['identity'] as Map),
    );
    if (identity.centerId != centerId || identity.username != username) {
      throw const ManagerAuthException('offlineLoginUnavailable');
    }
    cached['failures'] = 0;
    cached.remove('blockedUntil');
    await store.write(_key(username), jsonEncode(cached));
    return currentSession = ManagerSession(
      identity,
      ManagerSessionMode.offline,
      expiresAt: verified.add(offlineLifetime),
    );
  }

  Future<void> signOut() {
    currentSession = null;
    return gateway.signOut();
  }

  ManagerAccountGateway _onlineAccounts() {
    if (currentSession?.mode != ManagerSessionMode.online ||
        gateway is! ManagerAccountGateway) {
      throw const ManagerAuthException('onlineAccountChangeRequired');
    }
    return gateway as ManagerAccountGateway;
  }

  Future<void> updateProfile(String name, String email) async {
    final accounts = _onlineAccounts();
    final identity = currentSession!.identity;
    await accounts.updateName(name);
    if (email.trim() != identity.email) {
      await accounts.requestEmailChange(email);
    }
    final updated = ManagerIdentity(
      id: identity.id,
      centerId: identity.centerId,
      username: identity.username,
      name: name.trim(),
      email: email.trim(),
      manageAccounts: identity.manageAccounts,
      viewDiagnostics: identity.viewDiagnostics,
    );
    final raw = await store.read(_key(identity.username));
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      data['identity'] = updated.toJson();
      await store.write(_key(identity.username), jsonEncode(data));
    }
    currentSession = ManagerSession(updated, ManagerSessionMode.online);
  }

  Future<void> changePassword(String current, String next) async {
    final accounts = _onlineAccounts();
    if (next.length < 12) {
      throw const ManagerAuthException('securePasswordHint');
    }
    final username = currentSession!.identity.username;
    // Do not leave a stale offline verifier if the server accepts a new password
    // but the network fails before the response arrives.
    await store.write(_key(username), '');
    await accounts.changePassword(username, current, next);
    await signIn(username, next);
  }

  Future<ManagerIdentity> createManager({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    final accounts = _onlineAccounts();
    if (!currentSession!.identity.manageAccounts) {
      throw const ManagerAuthException('managerRequired');
    }
    if (password.length < 12) {
      throw const ManagerAuthException('securePasswordHint');
    }
    return accounts.createManager(
      username: username,
      name: name,
      email: email,
      initialPassword: password,
    );
  }
}
