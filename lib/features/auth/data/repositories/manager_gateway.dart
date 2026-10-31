import '../models/manager_identity.dart';

/// Supabase handles online passwords; the offline cache grants no cloud token.
abstract interface class ManagerGateway {
  Future<ManagerIdentity> signIn(String username, String password);
  Future<void> signOut();
}

class ManagerNetworkException implements Exception {
  const ManagerNetworkException();
}

abstract interface class ManagerAccountGateway implements ManagerGateway {
  Future<void> updateName(String name);
  Future<void> requestEmailChange(String email);
  Future<void> changePassword(String username, String current, String next);
  Future<ManagerIdentity> createManager({
    required String username,
    required String name,
    required String email,
    required String initialPassword,
  });
}
