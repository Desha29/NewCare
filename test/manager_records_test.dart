import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';

void main() {
  test('manager edits and deletes a case with audit history', () async {
    final repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    final record = repo.current.cases.first;
    await repo.updateRecord(ManagedRecordKind.caseRecord, record.id, {
      'title': 'Corrected case',
      'amount': 12345,
    }, 'Corrected receipt');
    expect(repo.current.cases.first.title, 'Corrected case');
    expect(repo.current.cases.first.amountMinor, 12345);
    await repo.deleteRecord(
      ManagedRecordKind.caseRecord,
      record.id,
      'Duplicate entry',
    );
    expect(repo.current.cases.any((c) => c.id == record.id), isFalse);
    expect(repo.current.audit.last.detail, contains('Duplicate entry'));
    expect(repo.current.audit.last.detail, contains('Corrected case'));
    await repo.dispose();
  });
  test(
    'deleting nursing archives referenced identity without orphaning cases',
    () async {
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await repo.deleteRecord(ManagedRecordKind.nursing, 'n1', 'Left center');
      expect(
        repo.current.staff.firstWhere((n) => n.id == 'n1').active,
        isFalse,
      );
      expect(repo.current.cases.any((c) => c.staffId == 'n1'), isTrue);
      await repo.dispose();
    },
  );
  test(
    'archiving shift preserves its case log and closes its active session',
    () async {
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      final count = repo.current.cases.length;
      await repo.deleteRecord(
        ManagedRecordKind.shift,
        'shift-demo',
        'Archived by manager',
      );
      expect(repo.current.activeShift, isNull);
      expect(repo.current.cases.length, count);
      await repo.dispose();
    },
  );
}
