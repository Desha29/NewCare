import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/string_store.dart';
import '../../../../core/storage/transactional_store.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../data/models/reconciliation.dart';
import '../../data/models/workspace_verification.dart';
import '../../data/repositories/cloud_sync_service.dart';

class DiagnosticsState {
  const DiagnosticsState({
    this.loading = false,
    this.failed = false,
    this.pending,
    this.checkedAt,
    this.localCounts = const {},
    this.remoteCounts = const {},
    this.status = ReconciliationStatus.unconfigured,
  });
  final bool loading, failed;
  final int? pending;
  final DateTime? checkedAt;
  final Map<String, int> localCounts;
  final Map<String, int> remoteCounts;
  final ReconciliationStatus status;
}

class DiagnosticsCubit extends Cubit<DiagnosticsState> {
  DiagnosticsCubit(this.repository, this.store, this.authorized, {this.sync})
    : super(const DiagnosticsState()) {
    _subscription = repository.changes.listen((_) {
      if (!state.loading) refresh(verifyCloud: false);
    });
  }
  final WorkspaceRepository repository;
  final StringStore store;
  final bool Function() authorized;
  final CloudSyncService? sync;
  late final StreamSubscription<Object?> _subscription;
  int _generation = 0;

  Future<void> refresh({bool verifyCloud = true}) async {
    final generation = ++_generation;
    if (!authorized()) {
      if (!isClosed) emit(const DiagnosticsState(failed: true));
      return;
    }
    emit(DiagnosticsState(loading: true, localCounts: state.localCounts));
    try {
      final verification = sync == null
          ? const WorkspaceVerification(ReconciliationStatus.unconfigured)
          : verifyCloud
          ? await sync!.verifyWorkspace()
          : const WorkspaceVerification(ReconciliationStatus.pending);
      final pending = store is TransactionalStore
          ? await (store as TransactionalStore).pendingCount()
          : null;
      if (isClosed || generation != _generation || !authorized()) return;
      final s = repository.current;
      emit(
        DiagnosticsState(
          pending: pending,
          checkedAt: DateTime.now(),
          localCounts: Map.unmodifiable(workspaceCounts(s)),
          remoteCounts: verification.remoteCounts,
          status: verification.status,
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
