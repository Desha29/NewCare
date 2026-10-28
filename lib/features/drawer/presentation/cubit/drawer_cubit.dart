import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/cash_movement.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
class DrawerCubit extends ActionCubit{
  DrawerCubit(this.repository);final WorkspaceRepository repository;
  Future<bool> save(CashMovement movement)=>execute(()=>repository.addMovement(movement));
}

