import '../../../../core/cubit/action_cubit.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
class ShiftCubit extends ActionCubit{
  ShiftCubit(this.repository);final WorkspaceRepository repository;
  Future<bool> start(String member,int amount,{String reason=''})=>execute(()=>repository.startShift(member,amount,reason:reason));
  Future<bool> join(String member)=>execute(()=>repository.joinShift(member));
  Future<bool> end(String note)=>execute(()=>repository.endShift(note));
}

