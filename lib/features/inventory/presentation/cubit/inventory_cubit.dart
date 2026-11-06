import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/stock_item.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../management/data/managed_record_kind.dart';

class InventoryCubit extends ActionCubit {
  InventoryCubit(this.repository);
  final WorkspaceRepository repository;

  Future<bool> saveItem(StockItem item) =>
      execute(() => repository.saveStockItem(item));

  Future<bool> deleteItem(String id, String reason) => execute(
    () => repository.deleteRecord(ManagedRecordKind.stockItem, id, reason),
  );
}
