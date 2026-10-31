import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/stock_item.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

class InventoryCubit extends ActionCubit {
  InventoryCubit(this.repository);
  final WorkspaceRepository repository;

  Future<bool> saveItem(StockItem item) =>
      execute(() => repository.saveStockItem(item));

  Future<bool> archiveItem(String id) =>
      execute(() => repository.archiveStockItem(id));
}

