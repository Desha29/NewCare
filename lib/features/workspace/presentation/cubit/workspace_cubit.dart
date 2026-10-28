import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/workspace_snapshot.dart';
import '../../data/repositories/workspace_repository.dart';

class WorkspaceCubit extends Cubit<WorkspaceSnapshot>{
  WorkspaceCubit(WorkspaceRepository repository):super(repository.current){_subscription=repository.changes.listen(emit);}
  late final StreamSubscription<WorkspaceSnapshot> _subscription;
  @override Future<void> close()async{await _subscription.cancel();return super.close();}
}

