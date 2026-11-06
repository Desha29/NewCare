import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/storage/transactional_store.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';
import 'package:newcare/features/sync/data/repositories/workspace_sync_gateway.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

class JournalStore extends MemoryStringStore implements TransactionalStore {
  final operations = <PendingOperation>[];
  @override
  Future<void> commit({
    required String key,
    required String value,
    required String operationId,
    required String action,
    required String payload,
  }) async {
    await write(key, value);
    operations.add(
      PendingOperation(
        id: operationId,
        action: action,
        payload: payload,
        sequence: operations.length + 1,
      ),
    );
  }

  @override
  Future<List<PendingOperation>> pending() async => List.of(operations);
  @override
  Future<int> pendingCount() async => operations.length;
  @override
  Future<void> acknowledge(String operationId) async =>
      operations.removeWhere((o) => o.id == operationId);
}

class FakeCloud implements WorkspaceSyncGateway {
  bool offline = false;
  bool loseResponse = false;
  final rows = <Map<String, dynamic>>[];
  Future<void> Function()? onPull;
  int pulls = 0;
  @override
  Future<void> ensureDevice() async {
    if (offline) throw StateError('offline');
  }

  @override
  Future<void> push(String centerId, PendingOperation operation) async {
    if (offline) throw StateError('offline');
    if (!rows.any((r) => r['operation_id'] == operation.id)) {
      rows.add({
        'sequence': rows.length + 1,
        'operation_id': operation.id,
        'payload': jsonDecode(operation.payload),
      });
    }
    if (loseResponse) {
      loseResponse = false;
      throw StateError('response lost');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pull(String centerId, int after) async {
    pulls++;
    await onPull?.call();
    onPull = null;
    return rows.where((r) => (r['sequence'] as int) > after).take(500).toList();
  }
}

void main() {
  late JournalStore store;
  late LocalWorkspaceRepository repository;
  late FakeCloud cloud;
  late CloudSyncService sync;
  setUp(() async {
    store = JournalStore();
    repository = LocalWorkspaceRepository(store, seedDemo: false);
    await repository.initialize();
    cloud = FakeCloud();
    sync = CloudSyncService(
      gateway: cloud,
      centerId: 'center',
      store: store,
      repository: repository,
      keyStore: store,
    );
  });
  tearDown(() async {
    sync.dispose();
    await repository.dispose();
  });

  test(
    'offline writes survive, retry after lost acknowledgement is idempotent',
    () async {
      await repository.addStaff(NursingMember(id: 'n', name: 'Nurse'));
      cloud.offline = true;
      await sync.sync();
      expect(sync.state, CloudSyncState.offline);
      expect(await store.pendingCount(), 1);
      cloud.offline = false;
      cloud.loseResponse = true;
      await sync.sync();
      expect(await store.pendingCount(), 1);
      await sync.sync();
      expect(cloud.rows, hasLength(1));
      expect(await store.pendingCount(), 0);
      expect(sync.state, CloudSyncState.online);
      expect(repository.current.staff.single.id, 'n');
    },
  );

  test(
    'pull drains more than one page and does not upload remote changes',
    () async {
      for (var i = 1; i <= 501; i++) {
        cloud.rows.add({
          'sequence': i,
          'operation_id': 'remote-$i',
          'payload': {
            'collections': {},
            'settings': {'managerName': 'Manager $i'},
          },
        });
      }
      await sync.sync();
      expect(cloud.pulls, 2);
      expect(repository.current.managerName, 'Manager 501');
      expect(await store.pendingCount(), 0);
    },
  );

  test('a local edit while pulling is preserved and remains pending', () async {
    cloud.rows.add({
      'sequence': 1,
      'operation_id': 'old',
      'payload': {
        'collections': {
          'staff': {
            'upsert': [NursingMember(id: 'n', name: 'Old').toJson()],
            'remove': [],
          },
        },
        'settings': {},
      },
    });
    cloud.onPull = () =>
        repository.addStaff(NursingMember(id: 'n', name: 'New'));
    await sync.sync();
    expect(repository.current.staff.single.name, 'New');
    expect(await store.pendingCount(), 1);
    expect(sync.state, isNot(CloudSyncState.online));
    await sync.sync();
    expect(await store.pendingCount(), 0);
    expect(repository.current.staff.single.name, 'New');
  });
}
