import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/case_stock_usage.dart';
import '../../data/models/stock_item.dart';

class CaseStockPicker extends StatefulWidget {
  const CaseStockPicker({
    super.key,
    required this.availableStock,
    required this.usages,
    required this.onChanged,
    this.compact = false,
  });

  final List<StockItem> availableStock;
  final List<CaseStockUsage> usages;
  final ValueChanged<List<CaseStockUsage>> onChanged;
  final bool compact;

  @override
  State<CaseStockPicker> createState() => _CaseStockPickerState();
}

class _CaseStockPickerState extends State<CaseStockPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usages = widget.usages;
    final activeStock = widget.availableStock.where((s) => s.active).toList();
    final usedIds = usages.map((u) => u.stockItemId).toSet();

    // Items that have remaining available stock or are currently used
    final filteredStock = activeStock.where((s) {
      final matchesQuery =
          _query.isEmpty ||
          s.name.toLowerCase().contains(_query.trim().toLowerCase());
      final hasStock = s.quantity > 0 || usedIds.contains(s.id);
      return matchesQuery && hasStock;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.t('usedSupplies'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (usages.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${usages.fold<int>(0, (sum, u) => sum + u.quantity)}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: widget.compact ? 6 : 8),
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: context.t('searchSupplies'),
            isDense: widget.compact,
            contentPadding: widget.compact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                : null,
            prefixIconConstraints: widget.compact
                ? const BoxConstraints(minWidth: 34)
                : null,
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
        SizedBox(height: widget.compact ? 6 : 8),
        if (activeStock.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              context.t('noStockItems'),
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
          )
        else ...[
          if (filteredStock.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                context.t('noResults'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.compact ? 110 : 160,
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in filteredStock) ...[
                      _buildStockChip(item),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (usages.isNotEmpty) ...[
          SizedBox(height: widget.compact ? 8 : 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            padding: EdgeInsets.all(widget.compact ? 6 : 10),
            child: Column(
              children: [
                for (var i = 0; i < usages.length; i++) ...[
                  if (i > 0) const Divider(height: 8, color: AppColors.border),
                  _buildUsageRow(i, usages[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockChip(StockItem item) {
    final usage = widget.usages
        .where((u) => u.stockItemId == item.id)
        .firstOrNull;
    final isSelected = usage != null;
    final maxAvailable = item.quantity + (usage?.quantity ?? 0);

    return FilterChip(
      avatar: isSelected
          ? const Icon(Icons.check, size: 14, color: AppColors.navy)
          : null,
      label: Text(
        isSelected
            ? '${item.name} (${usage.quantity})'
            : '${item.name} (${item.quantity})',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isSelected ? AppColors.navy : AppColors.text,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.tealLight,
      visualDensity: widget.compact
          ? VisualDensity.compact
          : VisualDensity.standard,
      materialTapTargetSize:
          widget.compact && MediaQuery.sizeOf(context).width >= 720
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      onSelected: (on) {
        if (on) {
          if (isSelected) {
            // Increment if available
            if (usage.quantity < maxAvailable) {
              final updated = [...widget.usages];
              final idx = updated.indexWhere((u) => u.stockItemId == item.id);
              updated[idx] = usage.copyWith(quantity: usage.quantity + 1);
              widget.onChanged(updated);
            }
          } else {
            // Add new
            final updated = [
              ...widget.usages,
              CaseStockUsage(
                stockItemId: item.id,
                name: item.name,
                quantity: 1,
              ),
            ];
            widget.onChanged(updated);
          }
        } else {
          // Deselect
          final updated = widget.usages
              .where((u) => u.stockItemId != item.id)
              .toList();
          widget.onChanged(updated);
        }
      },
    );
  }

  Widget _buildUsageRow(int index, CaseStockUsage usage) {
    final stock = widget.availableStock
        .where((s) => s.id == usage.stockItemId)
        .firstOrNull;
    final maxAvailable = (stock?.quantity ?? 0) + usage.quantity;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                usage.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              if (stock != null)
                Text(
                  '${context.t('stockQuantity')}: ${stock.quantity}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
                    fontFamily: 'Cairo',
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          onPressed: () {
            if (usage.quantity > 1) {
              final updated = [...widget.usages];
              updated[index] = usage.copyWith(quantity: usage.quantity - 1);
              widget.onChanged(updated);
            } else {
              final updated = [...widget.usages]..removeAt(index);
              widget.onChanged(updated);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '${usage.quantity}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          onPressed: usage.quantity < maxAvailable
              ? () {
                  final updated = [...widget.usages];
                  updated[index] = usage.copyWith(quantity: usage.quantity + 1);
                  widget.onChanged(updated);
                }
              : null,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
          onPressed: () {
            final updated = [...widget.usages]..removeAt(index);
            widget.onChanged(updated);
          },
        ),
      ],
    );
  }
}
