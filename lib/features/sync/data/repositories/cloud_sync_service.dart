import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/transactional_store.dart';
import '../../../../core/storage/string_store.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import 'workspace_sync_gateway.dart';
import '../models/reconciliation.dart';
import '../models/workspace_verification.dart';
import '../../../workspace/data/repositories/local_workspace_repository.dart';

enum CloudSyncState { offline, syncing, online, pending }

/// Uploads the encrypted local journal only after the device is enrolled.
/// The server is the authority; a failed upload stays pending for retry.
class CloudSyncService extends ChangeNotifier with WidgetsBindingObserver {
  CloudSyncService({
    SupabaseClient? client,
    WorkspaceSyncGateway? gateway,
    required this.centerId,
    required this.store,
    required this.repository,
    required this.keyStore,
  }) : gateway = gateway ?? SupabaseWorkspaceSyncGateway(client!);

  final WorkspaceSyncGateway gateway;
  final String centerId;
  final TransactionalStore store;
  final WorkspaceRepository repository;
  final StringStore keyStore;
  Future<void>? _running;
  Timer? _retry;
  StreamSubscription<Object?>? _changes;
  bool _disposed = false;
  CloudSyncState state = CloudSyncState.offline;
  int pendingOperations = 0;
  Object? lastError;
  String get cursorKey => 'newcare.cloud-sync-sequence.v1.$centerId';

  void start() {
    if (_retry != null || _disposed) return;
    WidgetsBinding.instance.addObserver(this);
    _changes = repository.changes.listen((_) => unawaited(sync()));
    _retry = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(sync()),
    );
    unawaited(sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(sync());
  }

  Future<void> sync() {
    if (_disposed) return Future.value();
    return _running ??= _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    _log('START pending=$pendingOperations');
    state = CloudSyncState.syncing;
    lastError = null;
    _notify();
    try {
      await _drain();
      pendingOperations = await store.pendingCount();
      state = pendingOperations == 0
          ? CloudSyncState.online
          : CloudSyncState.pending;
      _log('SUCCESS pending=$pendingOperations');
    } catch (error) {
      state = CloudSyncState.offline;
      lastError = error;
      _log('ERROR ${error.runtimeType}');
    }
    try {
      pendingOperations = await store.pendingCount();
    } catch (_) {}
    _notify();
  }

  Future<void> _drain() async {
    await gateway.ensureDevice();
    final pending = await store.pending();
    pendingOperations = pending.length;
    _notify();
    for (final operation in pending) {
      if (_disposed) return;
      await gateway.push(centerId, operation);
      await store.acknowledge(operation.id);
    }
    await _pull();
  }

  Future<void> _pull() async {
    _log('PULL_START');
    var after = int.tryParse(await keyStore.read(cursorKey) ?? '') ?? 0;
    while (!_disposed) {
      final rows = await gateway.pull(centerId, after);
      for (final value in rows) {
        final sequence = (value['sequence'] as num).toInt();
        if (sequence <= after) {
          throw StateError('Cloud sequence did not advance');
        }
        await repository.applyRemoteChange(
          Map<String, dynamic>.from(value['payload'] as Map),
        );
        // Persist only after the snapshot. A crash in between safely replays the
        // idempotent delta, rather than skipping a change which was not saved.
        await keyStore.write(cursorKey, sequence.toString());
        after = sequence;
      }
      if (rows.length < 500) break;
    }
    _log('PULL_END sequence=$after');
  }

  /// A full replay is deliberately separate from the lightweight header check.
  /// Matching counts alone never produce a "matched" result.
  Future<WorkspaceVerification> verifyWorkspace() async {
    await sync();
    if (state == CloudSyncState.offline) {
      return const WorkspaceVerification(ReconciliationStatus.unavailable);
    }
    if (await store.pendingCount() != 0) {
      return const WorkspaceVerification(ReconciliationStatus.pending);
    }
    final snapshot = repository.current;
    final revision = int.tryParse(await keyStore.read(cursorKey) ?? '') ?? 0;
    final remote = LocalWorkspaceRepository(
      MemoryStringStore(),
      seedDemo: false,
    );
    await remote.initialize();
    try {
      var after = 0;
      while (true) {
        final rows = await gateway.pull(centerId, after);
        for (final row in rows) {
          final sequence = (row['sequence'] as num).toInt();
          if (sequence <= after) throw StateError('Invalid cloud sequence');
          await remote.applyRemoteChange(
            Map<String, dynamic>.from(row['payload'] as Map),
          );
          after = sequence;
        }
        if (rows.length < 500) break;
      }
      final localManifest = await DataManifest.create(
        scope: centerId,
        revision: revision,
        data: snapshot.toJson(),
        counts: workspaceCounts(snapshot),
      );
      final remoteCounts = workspaceCounts(remote.current);
      final remoteManifest = await DataManifest.create(
        scope: centerId,
        revision: after,
        data: remote.current.toJson(),
        counts: remoteCounts,
      );
      final pending = await store.pendingCount();
      if (!identical(snapshot, repository.current)) {
        return WorkspaceVerification(
          ReconciliationStatus.pending,
          remoteCounts: remoteCounts,
        );
      }
      return WorkspaceVerification(
        reconcile(
          configured: true,
          authenticated: true,
          online: true,
          pendingCount: pending,
          conflictCount: 0,
          local: localManifest,
          remote: remoteManifest,
        ),
        remoteCounts: remoteCounts,
      );
    } catch (_) {
      return const WorkspaceVerification(ReconciliationStatus.unavailable);
    } finally {
      await remote.dispose();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _changes?.cancel();
    if (_retry != null) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _log(String message) {
    if (kDebugMode) {
      developer.log('[NewCare][SYNC] $message', name: 'newcare.sync');
    }
  }
}
