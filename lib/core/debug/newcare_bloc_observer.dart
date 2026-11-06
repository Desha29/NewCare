import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../../features/workspace/data/models/workspace_snapshot.dart';
import '../cubit/action_cubit.dart';

class NewCareBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _log('CREATE', bloc, 'state=${_stateSummary(bloc.state)}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log(
      'CHANGE',
      bloc,
      'from=${_stateSummary(change.currentState)} '
          'to=${_stateSummary(change.nextState)}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _log(
      'TRANSITION',
      bloc,
      'event=${transition.event.runtimeType} '
          'from=${_stateSummary(transition.currentState)} '
          'to=${_stateSummary(transition.nextState)}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _log('ERROR', bloc, 'error=${error.runtimeType}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    _log('CLOSE', bloc, '');
    super.onClose(bloc);
  }

  void _log(String phase, BlocBase<dynamic> bloc, String details) {
    if (!kDebugMode) return;
    developer.log(
      '[NewCare][$phase][${bloc.runtimeType}]'
      '${details.isEmpty ? '' : ' $details'}',
      name: 'newcare.bloc',
    );
  }

  String _stateSummary(Object? state) {
    if (state is ActionState) {
      return 'ActionState(busy=${state.busy},error=${state.error ?? 'none'})';
    }
    if (state is AppState) {
      return 'AppState(page=${state.page.name},managerUnlocked=${state.managerUnlocked})';
    }
    if (state is WorkspaceSnapshot) {
      return 'WorkspaceSnapshot(cases=${state.cases.length},staff=${state.staff.length},'
          'pendingState=local)';
    }
    return state.runtimeType.toString();
  }
}
