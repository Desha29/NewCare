import '../../../../core/cubit/action_cubit.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../catalogue/data/models/supply_item.dart';
import '../../data/managed_record_kind.dart';

class ManagementCubit extends ActionCubit {
  Future<bool> updateRecord(
    ManagedRecordKind kind,
    String id,
    Map<String, dynamic> fields,
    String reason,
  ) => execute(() => repository.updateRecord(kind, id, fields, reason));
  Future<bool> deleteRecord(ManagedRecordKind kind, String id, String reason) =>
      execute(() => repository.deleteRecord(kind, id, reason));
  ManagementCubit(this.repository);
  final WorkspaceRepository repository;
  Future<bool> addStaff(NursingMember member) =>
      execute(() => repository.addStaff(member));
  Future<bool> addProcedure(Procedure procedure) =>
      execute(() => repository.addProcedure(procedure));
  Future<bool> addSupply(SupplyItem supply) =>
      execute(() => repository.addSupply(supply));
  Future<bool> settings({
    String? name,
    String? email,
    int? opening,
    Map<String, List<String>>? permissions,
    bool? complete,
  }) => execute(
    () => repository.saveSettings(
      managerName: name,
      managerEmail: email,
      openingMinor: opening,
      permissions: permissions,
      setupDone: complete,
    ),
  );
}
