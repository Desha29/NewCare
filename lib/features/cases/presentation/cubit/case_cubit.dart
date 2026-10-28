import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/case_record.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

class CaseCubit extends ActionCubit {
  CaseCubit(this.repository);
  final WorkspaceRepository repository;
  Future<bool> save(CaseRecord record) =>
      execute(() => repository.addCase(record));
}
