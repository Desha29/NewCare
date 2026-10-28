import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/workspace/data/repositories/workspace_repository.dart';

class ActionState {const ActionState({this.busy=false,this.error});final bool busy;final String? error;}
abstract class ActionCubit extends Cubit<ActionState>{
  ActionCubit():super(const ActionState());
  Future<bool> execute(Future<void> Function() action)async{
    if(state.busy)return false;emit(const ActionState(busy:true));
    try{await action();if(!isClosed)emit(const ActionState());return true;}
    on WorkspaceException catch(e){if(!isClosed)emit(ActionState(error:e.code));return false;}
    on FormatException {if(!isClosed)emit(const ActionState(error:'invalidAmount'));return false;}
    catch(_){if(!isClosed)emit(const ActionState(error:'saveFailed'));return false;}
  }
}

