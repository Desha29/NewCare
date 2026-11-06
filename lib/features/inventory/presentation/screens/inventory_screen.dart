import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../management/presentation/widgets/management_form_dialog.dart';
import '../../../management/presentation/widgets/catalogue_delete_dialog.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/stock_item.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/stock_item_editor.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => InventoryCubit(ctx.read<WorkspaceRepository>()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final allItems = data.stockItems.where((i) => i.active).toList();
    final items = search.trim().isEmpty
        ? allItems
        : allItems
              .where(
                (i) =>
                    i.name.toLowerCase().contains(search.trim().toLowerCase()),
              )
              .toList();

    return NcPageColumn(
      maxWidth: 1000,
      children: [
        NcActionRow(
          children: [
            NcButton(
              label: context.t('addStockItem'),
              icon: Icons.add,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogCtx) => BlocProvider.value(
                  value: context.read<InventoryCubit>(),
                  child: StockItemEditor(
                    onSaved: () => Navigator.pop(dialogCtx),
                  ),
                ),
              ),
            ),
          ],
        ),
        NcCard(
          title: context.t('inventory'),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: context.t('search'),
                prefixIcon: const Icon(Icons.search, size: 18),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
            const SizedBox(height: 12),
            if (allItems.isEmpty)
              NcEmpty(message: context.t('noStockItems'))
            else if (items.isEmpty)
              NcEmpty(message: context.t('noResults'))
            else
              NcAdaptiveTable(
                headers: [context.t('itemName'), context.t('stockQuantity')],
                emptyLabel: context.t('noResults'),
                columnWidths: const [300, 120],
                rows: List.generate(items.length, (i) => List.filled(2, '')),
                cellBuilder: (rowIdx, colIdx, val) {
                  final item = items[rowIdx];
                  if (colIdx == 0) {
                    return Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.quantity > 0
                          ? AppColors.tealLight
                          : AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: item.quantity > 0
                            ? AppColors.navy
                            : AppColors.danger,
                      ),
                    ),
                  );
                },
                actions: (rowIdx) {
                  final item = items[rowIdx];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: context.t('edit'),
                        onPressed: () => ManagementFormDialog.open(
                          context,
                          (dialogCtx) => BlocProvider.value(
                            value: context.read<InventoryCubit>(),
                            child: StockItemEditor(
                              initial: item,
                              onSaved: () => Navigator.pop(dialogCtx),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: AppColors.danger,
                        tooltip: context.t('delete'),
                        onPressed: () => _confirmDelete(context, item),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, StockItem item) {
    final cubit = context.read<InventoryCubit>();
    final title = context.t('deleteStockItem');
    return CatalogueDeleteDialog.open(
      context,
      title: title,
      name: item.name,
      detail: context.t('deleteStockItemHelp'),
      action: cubit,
      onDelete: () => cubit.deleteItem(item.id, title),
    );
  }
}
