import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../data/models/case_stock_usage.dart';
import '../../data/models/stock_item.dart';

class CaseStockPicker extends StatelessWidget {
  const CaseStockPicker({
    super.key,
    required this.availableStock,
    required this.usages,
    required this.onChanged,
  });

  final List<StockItem> availableStock;
  final List<CaseStockUsage> usages;
  final ValueChanged<List<CaseStockUsage>> onChanged;

  @override
  Widget build(BuildContext context) {
    final activeStock = availableStock.where((s) => s.active).toList();
    final usedIds = usages.map((u) => u.stockItemId).toSet();
    final remainingOptions =
        activeStock.where((s) => !usedIds.contains(s.id) && s.quantity > 0).toList();

    return NcCard(
      title: context.t('usedSupplies'),
      children: [
        if (usages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.t('noSuppliesUsed'),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: usages.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final usage = usages[i];
              final stock =
                  availableStock.where((s) => s.id == usage.stockItemId).firstOrNull;
              final maxAvailable = (stock?.quantity ?? 0) + usage.quantity;

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  usage.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: stock != null
                    ? Text('${context.t('stockQuantity')}: ${stock.quantity}')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: usage.quantity > 1
                          ? () {
                              final updated = [...usages];
                              updated[i] = usage.copyWith(
                                quantity: usage.quantity - 1,
                              );
                              onChanged(updated);
                            }
                          : null,
                    ),
                    Text(
                      '${usage.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: usage.quantity < maxAvailable
                          ? () {
                              final updated = [...usages];
                              updated[i] = usage.copyWith(
                                quantity: usage.quantity + 1,
                              );
                              onChanged(updated);
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () {
                        final updated = [...usages]..removeAt(i);
                        onChanged(updated);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        if (remainingOptions.isNotEmpty) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<StockItem>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.t('addStockItem'),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              for (final s in remainingOptions)
                DropdownMenuItem(
                  value: s,
                  child: Text('${s.name} (${context.t('stockQuantity')}: ${s.quantity})'),
                ),
            ],
            onChanged: (selected) {
              if (selected == null) return;
              final updated = [
                ...usages,
                CaseStockUsage(
                  stockItemId: selected.id,
                  name: selected.name,
                  quantity: 1,
                ),
              ];
              onChanged(updated);
            },
          ),
        ],
      ],
    );
  }
}

