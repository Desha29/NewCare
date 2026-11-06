import '../models/manager_identity.dart';
import '../../../workspace/data/sources/manager_staff_projection.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

Future<void> prepareCenterWorkspace({
  required WorkspaceRepository repository,
  required ManagerIdentity identity,
  required Future<void> Function() restore,
  required Future<void> Function() markReady,
}) async {
  // Restore before creating any local projection, otherwise its default salary
  // and phone would become a later cloud upsert over the manager's real data.
  await restore();
  await ensureManagerStaff(repository, identity);
  await repository.saveSettings(
    managerName: identity.name,
    managerEmail: identity.email,
    setupDone: true,
  );
  await markReady();
}
