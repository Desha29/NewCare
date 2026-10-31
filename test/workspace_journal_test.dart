import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/sqlite_string_store.dart';
import 'package:newcare/core/storage/storage_cipher.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  test(
    'repository persists one delta atomically and deduplicates staff retry',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'newcare-journal-',
      );
      final store = await SqliteStringStore.open(
        path: '${directory.path}/data.db',
        cipher: StorageCipher(List<int>.filled(32, 3)),
      );
      final repository = LocalWorkspaceRepository(store, seedDemo: false);
      try {
        await repository.initialize();
        expect(await store.pending(), isEmpty); // no synthetic demo uploads
        final member = NursingMember(id: 'staff-1', name: 'Test Nurse');
        await repository.addStaff(member);
        await repository.addStaff(member);
        final operations = await store.pending();
        expect(operations, hasLength(1));
        expect(operations.single.action, 'staffAdded');
        final delta = jsonDecode(operations.single.payload) as Map;
        expect(
          (delta['collections'] as Map).keys,
          containsAll(['staff', 'audit']),
        );
        expect((delta['collections'] as Map).containsKey('cases'), isFalse);
        expect(repository.current.staff.single.id, 'staff-1');
      } finally {
        await repository.dispose();
        await store.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
