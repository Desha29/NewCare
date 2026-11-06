import '../models/manager_identity.dart';

abstract interface class CenterSetupGateway {
  Future<void> requestFirstManager(String username, String password);
  Future<ManagerIdentity> activateFirstManager({
    required String username,
    required String name,
    required String email,
    required String password,
  });
}
