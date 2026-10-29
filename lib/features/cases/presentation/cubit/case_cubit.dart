import '../../data/models/case_payment.dart';
import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/case_record.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../management/data/managed_record_kind.dart';

class CaseCubit extends ActionCubit {
  CaseCubit(this.repository);
  final WorkspaceRepository repository;
  Future<bool> setPrice(String id, int total) => execute(
    () => repository.updateRecord(ManagedRecordKind.caseRecord, id, {
      'agreedTotal': total,
    }, 'casePriceUpdated'),
  );
  Future<bool> receive(CasePayment payment) =>
      execute(() => repository.addCasePayment(payment));
  Future<bool> save(CaseRecord record) =>
      execute(() => repository.addCase(record));
  Future<bool> update(CaseRecord record) => execute(
    () => repository.updateRecord(
      ManagedRecordKind.caseRecord,
      record.id,
      record.toJson(),
      'caseUpdated',
    ),
  );
}
