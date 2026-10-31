import 'package:uuid/uuid.dart';

import '../../../cases/data/models/case_record.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../models/case_stock_usage.dart';
import '../models/stock_movement.dart';

abstract final class StockChanges {
  static WorkspaceSnapshot applyUsage(
    WorkspaceSnapshot data,
    CaseRecord? before,
    CaseRecord after,
  ) {
    final Map<String, CaseStockUsage> previous = {
      for (final u in before?.stockUsages ?? const <CaseStockUsage>[])
        u.stockItemId: u,
    };
    final Map<String, CaseStockUsage> next = {
      for (final u in after.stockUsages) u.stockItemId: u,
    };
    if (next.length != after.stockUsages.length ||
        after.stockUsages.any((u) => u.quantity <= 0)) {
      throw const WorkspaceException('invalidStockQuantity');
    }
    var items = data.stockItems.toList();
    final movements = <StockMovement>[];
    for (final id in {...previous.keys, ...next.keys}) {
      final item = items.where((s) => s.id == id).firstOrNull;
      if (item == null) throw const WorkspaceException('stockNotFound');
      final int old = previous[id]?.quantity ?? 0;
      final int newQuantity = next[id]?.quantity ?? 0;
      final int consumed = newQuantity - old;
      if (consumed > 0 && (!item.active || consumed > item.quantity)) {
        throw const WorkspaceException('insufficientStock');
      }
      final usage = next[id];
      if (usage != null && usage.name != (previous[id]?.name ?? item.name)) {
        throw const WorkspaceException('stockChanged');
      }
      if (consumed == 0) continue;
      items = items
          .map(
            (s) => s.id == id
                ? s.copyWith(
                    quantity: s.quantity - consumed,
                    version: s.version + 1,
                  )
                : s,
          )
          .toList();
      movements.add(
        StockMovement(
          id: const Uuid().v4(),
          stockItemId: id,
          name: previous[id]?.name ?? item.name,
          delta: -consumed,
          kind: 'caseUsage',
          at: DateTime.now(),
          caseId: after.id,
          staffId: after.staffId,
        ),
      );
    }
    return data.copyWith(
      stockItems: items,
      stockMovements: [...data.stockMovements, ...movements],
    );
  }
}
