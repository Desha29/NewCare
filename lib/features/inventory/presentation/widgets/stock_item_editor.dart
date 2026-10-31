import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../data/models/stock_item.dart';
import '../cubit/inventory_cubit.dart';

class StockItemEditor extends StatefulWidget {
  const StockItemEditor({super.key, this.initial, this.onSaved});
  final StockItem? initial;
  final VoidCallback? onSaved;

  @override
  State<StockItemEditor> createState() => _StockItemEditorState();
}

class _StockItemEditorState extends State<StockItemEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initial?.name ?? '');
    quantityController = TextEditingController(
      text: widget.initial?.quantity.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Form(
      key: form,
      child: NcCard(
        title: isEdit ? context.t('editStockItem') : context.t('addStockItem'),
        children: [
          const OperationError<InventoryCubit>(),
          NcField(
            label: context.t('itemName'),
            hint: context.t('itemName'),
            controller: nameController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? context.t('requiredField') : null,
          ),
          NcField(
            label: context.t('stockQuantity'),
            controller: quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.t('requiredField');
              final parsed = int.tryParse(v);
              if (parsed == null || parsed < 0) return context.t('invalidAmount');
              return null;
            },
          ),
          const SizedBox(height: 8),
          NcButton(
            label: isEdit ? context.t('save') : context.t('add'),
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              final cubit = context.read<InventoryCubit>();
              final qty = int.parse(quantityController.text.trim());
              final item = widget.initial == null
                  ? StockItem(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      quantity: qty,
                    )
                  : widget.initial!.copyWith(
                      name: nameController.text.trim(),
                      quantity: qty,
                    );
              final success = await cubit.saveItem(item);
              if (success && mounted) {
                widget.onSaved?.call();
              }
            },
          ),
        ],
      ),
    );
  }
}

