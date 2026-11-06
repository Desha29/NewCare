import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';

import 'cloud_sync_service_test.dart' show JournalStore, FakeCloud;
import 'support/production_workflow_fixture.dart';

void main() {
  test('catalogue deletion removes rows, preserves historical snapshots, and synchronizes tombstones', () async {
    final store = JournalStore();
    final repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await populateProductionWorkflow(repo);
    final cloud = FakeCloud();
    final sync = CloudSyncService(
      gateway: cloud,
      centerId: 'c',
      store: store,
      repository: repo,
      keyStore: store,
    );
    await sync.sync();
    await repo.deleteRecord(
      ManagedRecordKind.stockItem,
      'qa-stock',
      'Delete stock',
    );
    await repo.deleteRecord(
      ManagedRecordKind.labTest,
      'qa-test',
      'Delete test',
    );
    expect(repo.current.stockItems, isEmpty);
    expect(repo.current.labTests, isEmpty);
    expect(repo.current.cases.first.stockUsages.single.name, 'شاش تجريبي');
    expect(repo.current.stockMovements, isNotEmpty);
    expect(repo.current.labOrders.single.items.single.name, 'تحليل تجريبي');
    expect(repo.current.labOrders.single.totalMinor, 10000);
    await repo.updateRecord(ManagedRecordKind.caseRecord, 'qa-in', {
      'agreedTotal': 12000,
    }, 'price correction');
    final otherStore = JournalStore();
    final other = LocalWorkspaceRepository(otherStore, seedDemo: false);
    await other.initialize();
    final pull = CloudSyncService(
      gateway: cloud,
      centerId: 'c',
      store: otherStore,
      repository: other,
      keyStore: otherStore,
    );
    try {
      await sync.sync();
      await pull.sync();
      expect(other.current.stockItems, isEmpty);
      expect(other.current.labTests, isEmpty);
      expect(other.current.cases.first.stockUsages.single.quantity, 2);
      expect(other.current.labOrders.single.items.single.name, 'تحليل تجريبي');
      expect(other.current.toJson(), repo.current.toJson());
    } finally {
      sync.dispose();
      pull.dispose();
      await repo.dispose();
      await other.dispose();
    }
  });
}
