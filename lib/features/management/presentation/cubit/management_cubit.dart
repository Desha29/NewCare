import '../../../../core/cubit/action_cubit.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../catalogue/data/models/supply_item.dart';
class ManagementCubit extends ActionCubit {
  ManagementCubit(this.repository);final WorkspaceRepository repository;
  Future<bool> addStaff(NursingMember member)=>execute(()=>repository.addStaff(member));
  Future<bool> addProcedure(Procedure procedure)=>execute(()=>repository.addProcedure(procedure));
  Future<bool> addSupply(SupplyItem supply)=>execute(()=>repository.addSupply(supply));
  Future<bool> settings({String? name,String? email,int? opening,Map<String,List<String>>? permissions,bool? complete})=>execute(()=>repository.saveSettings(managerName:name,managerEmail:email,openingMinor:opening,permissions:permissions,setupDone:complete));
}

