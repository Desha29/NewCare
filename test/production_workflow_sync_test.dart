import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/sqlite_string_store.dart';
import 'package:newcare/core/storage/storage_cipher.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';
import 'package:newcare/features/sync/data/models/reconciliation.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

import 'cloud_sync_service_test.dart' show FakeCloud;
import 'support/production_workflow_fixture.dart';

void main() {
  test('all operational collections survive SQLite restart, upload, and full cloud restore', () async {
    final dir = await Directory.systemTemp.createTemp('newcare-workflow-');
    final cipher = StorageCipher(List<int>.filled(32, 27));
    var store = await SqliteStringStore.open(
      path: '${dir.path}/source.db',
      cipher: cipher,
    );
    var repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await populateProductionWorkflow(repo);
    final expected = repo.current.toJson();
    expect(repo.current.stockItems.single.quantity, 7);
    expect(repo.current.drawerBalance, 16600);
    expect(repo.current.labOrders.single.received, isTrue);
    expect(repo.current.labOrders.single.totalMinor, 10000);
    expect(repo.current.staff.first.salaryMinor, 500000);
    expect(await store.pendingCount(), greaterThan(20));
    await repo.dispose();
    await store.close();
    store = await SqliteStringStore.open(
      path: '${dir.path}/source.db',
      cipher: cipher,
    );
    repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    expect(repo.current.toJson(), expected);
    final cloud = FakeCloud();
    final sync = CloudSyncService(
      gateway: cloud,
      centerId: 'center',
      store: store,
      repository: repo,
      keyStore: store,
    );
    final restoredStore = await SqliteStringStore.open(
      path: '${dir.path}/restored.db',
      cipher: cipher,
    );
    final restored = LocalWorkspaceRepository(restoredStore, seedDemo: false);
    await restored.initialize();
    final pull = CloudSyncService(
      gateway: cloud,
      centerId: 'center',
      store: restoredStore,
      repository: restored,
      keyStore: restoredStore,
    );
    try {
      await sync.sync();
      expect(sync.state, CloudSyncState.online);
      expect(await store.pendingCount(), 0);
      await pull.sync();
      expect(pull.state, CloudSyncState.online);
      expect(restored.current.toJson(), expected);
      expect(await restoredStore.pendingCount(), 0);
      expect(
        (await pull.verifyWorkspace()).status,
        ReconciliationStatus.matched,
      );
    } finally {
      sync.dispose();
      pull.dispose();
      await repo.dispose();
      await restored.dispose();
      await store.close();
      await restoredStore.close();
      await dir.delete(recursive: true);
    }
  });
}
