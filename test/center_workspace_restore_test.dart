import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/prepare_center_workspace.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

import 'cloud_sync_service_test.dart' show JournalStore, FakeCloud;

void main() {
  test('existing manager restore preserves salary and phone before local projection', () async {
    final store = JournalStore();
    final repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    final remote = const NursingMember(
      id: 'm',
      name: 'Manager',
      isManager: true,
      salaryMinor: 700000,
      phone: '01234567890',
    );
    final cloud = FakeCloud();
    cloud.rows.add({
      'sequence': 1,
      'operation_id': 'original',
      'payload': {
        'version': 1,
        'settings': {},
        'collections': {
          'staff': {
            'upsert': [remote.toJson()],
            'remove': [],
          },
        },
      },
    });
    final sync = CloudSyncService(
      gateway: cloud,
      centerId: 'c',
      store: store,
      repository: repo,
      keyStore: store,
    );
    var ready = false;
    await prepareCenterWorkspace(
      repository: repo,
      identity: const ManagerIdentity(
        id: 'm',
        centerId: 'c',
        username: 'manager',
        name: 'Manager',
        email: 'contact@example.invalid',
        manageAccounts: true,
        viewDiagnostics: true,
      ),
      restore: sync.sync,
      markReady: () async {
        ready = true;
      },
    );
    expect(repo.current.staff.single.salaryMinor, 700000);
    expect(repo.current.staff.single.phone, '01234567890');
    expect(ready, isTrue);
    await sync.sync();
    expect(repo.current.staff.single.salaryMinor, 700000);
    sync.dispose();
    await repo.dispose();
  });
}
