import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/sources/manager_staff_projection.dart';

void main() {
  test('verified manager is available for correct case attribution without a cloud pull', () async {
    final repo = LocalWorkspaceRepository(MemoryStringStore(), seedDemo: false);
    await repo.initialize();
    const identity = ManagerIdentity(
      id: 'manager-b',
      centerId: 'center-1',
      username: 'manager_b',
      name: 'Manager B',
      email: 'contact@example.invalid',
      manageAccounts: false,
      viewDiagnostics: false,
    );
    await ensureManagerStaff(repo, identity);
    await ensureManagerStaff(repo, identity);
    expect(repo.current.staff, hasLength(1));
    expect(repo.current.staff.single.id, 'manager-b');
    expect(repo.current.staff.single.isManager, isTrue);
    await repo.dispose();
  });
}
