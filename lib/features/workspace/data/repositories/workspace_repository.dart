import '../../../cases/data/models/case_record.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../models/workspace_snapshot.dart';
import '../../../catalogue/data/models/supply_item.dart';

class WorkspaceException implements Exception {
  const WorkspaceException(this.code);
  final String code;
}

abstract interface class WorkspaceRepository {
  WorkspaceSnapshot get current;
  Stream<WorkspaceSnapshot> get changes;
  Future<void> initialize();
  Future<void> startShift(
    String staffId,
    int countedMinor, {
    String reason = '',
  });
  Future<void> joinShift(String staffId);
  Future<void> endShift(String note);
  Future<void> addCase(CaseRecord record);
  Future<void> addMovement(CashMovement movement);
  Future<void> addStaff(NursingMember member);
  Future<void> addProcedure(Procedure procedure);
  Future<void> addSupply(SupplyItem supply);
  Future<void> saveSettings({
    String? managerName,
    String? managerEmail,
    int? openingMinor,
    Map<String, List<String>>? permissions,
    bool? setupDone,
  });
  Future<void> dispose();
}
