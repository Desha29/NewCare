import '../../../auth/data/models/manager_identity.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../repositories/workspace_repository.dart';

/// Reconcile a server-verified manager identity before allowing case entry.
Future<void> ensureManagerStaff(
  WorkspaceRepository repository,
  ManagerIdentity identity,
) async {
  final existing = repository.current.staff
      .where((s) => s.id == identity.id)
      .firstOrNull;
  if (existing == null) {
    await repository.addStaff(
      NursingMember(id: identity.id, name: identity.name, isManager: true),
    );
  } else if (existing.name != identity.name || !existing.isManager) {
    await repository.updateRecord(ManagedRecordKind.nursing, identity.id, {
      'name': identity.name,
      'isManager': true,
    }, 'managerIdentityRefreshed');
  }
}
