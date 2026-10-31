import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/string_store.dart';
import '../../../../core/storage/transactional_store.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

class DiagnosticsState {
  const DiagnosticsState({
    this.loading = false,
    this.failed = false,
    this.pending,
    this.checkedAt,
    this.localCounts = const {},
  });
  final bool loading, failed;
  final int? pending;
  final DateTime? checkedAt;
  final Map<String, int> localCounts;
}

class DiagnosticsCubit extends Cubit<DiagnosticsState> {
  DiagnosticsCubit(this.repository, this.store, this.authorized)
    : super(const DiagnosticsState()) {
    _subscription = repository.changes.listen((_) => refresh());
  }
  final WorkspaceRepository repository;
  final StringStore store;
  final bool Function() authorized;
  late final StreamSubscription<Object?> _subscription;
  int _generation = 0;

  Future<void> refresh() async {
    final generation = ++_generation;
    if (!authorized()) {
      if (!isClosed) emit(const DiagnosticsState(failed: true));
      return;
    }
    emit(DiagnosticsState(loading: true, localCounts: state.localCounts));
    try {
      final pending = store is TransactionalStore
          ? await (store as TransactionalStore).pendingCount()
          : null;
      if (isClosed || generation != _generation || !authorized()) return;
      final s = repository.current;
      emit(
        DiagnosticsState(
          pending: pending,
          checkedAt: DateTime.now(),
          localCounts: Map.unmodifiable({
            'cases': s.cases.length,
            'nursing': s.staff.length,
            'procedure': s.procedures.length,
            'transactions': s.movements.length,
            'diagnosticsPayments': s.payments.length,
            'drawerHandoverHistory': s.handovers.length,
          }),
        ),
      );
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(const DiagnosticsState(failed: true));
      }
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    await _subscription.cancel();
    return super.close();
  }
}
