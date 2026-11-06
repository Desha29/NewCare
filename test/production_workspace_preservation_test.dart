import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/models/workspace_snapshot.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  test('production startup never guesses that user records are disposable demo data', () async {
    final store = MemoryStringStore();
    final saved = WorkspaceSnapshot(
      staff: [
        const NursingMember(id: 'n1', name: 'محمود أحمد', salaryMinor: 400000),
      ],
    );
    await store.write(
      LocalWorkspaceRepository.storageKey,
      jsonEncode(saved.toJson()),
    );
    final repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    expect(repo.current.toJson(), saved.toJson());
    await repo.dispose();
  });
}
