import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/case_record.dart';
import '../cubit/case_cubit.dart';

/// A nursing price correction never changes receipts or their dates.
class CasePriceDialog extends StatefulWidget {
  const CasePriceDialog({super.key, required this.record});
  final CaseRecord record;
  static Future<void> open(BuildContext context, CaseRecord record) =>
      showDialog<void>(
        context: context,
        builder: (_) => CasePriceDialog(record: record),
      );
  @override
  State<CasePriceDialog> createState() => _CasePriceDialogState();
}

class _CasePriceDialogState extends State<CasePriceDialog> {
  final form = GlobalKey<FormState>();
  late final total = TextEditingController(
    text: (widget.record.invoiceMinor / 100).toStringAsFixed(2),
  );
  @override
  void dispose() {
    total.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final current = data.cases
        .where((c) => c.id == widget.record.id)
        .firstOrNull;
    if (current == null) return const SizedBox.shrink();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: NcCard(
              title: context.t('editCasePrice'),
              children: [
                Text(current.title),
                const OperationError<CaseCubit>(),
                Text(
                  '${context.t('paidTotal')}: ${context.money(data.paidFor(current))}',
                ),
                NcField(
                  label: context.t('agreedPrice'),
                  controller: total,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    try {
                      return Money.parse(v ?? '') < data.paidFor(current)
                          ? context.t('priceBelowPaid')
                          : null;
                    } catch (_) {
                      return context.t('invalidAmount');
                    }
                  },
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: total,
                  builder: (context, _, _) {
                    try {
                      return Text(
                        '${context.t('remainingAmount')}: ${context.money(Money.parse(total.text) - data.paidFor(current))}',
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                Text(
                  context.t('priceEditNote'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    NcButton(
                      label: context.t('save'),
                      busy: context.watch<CaseCubit>().state.busy,
                      onPressed: () async {
                        if (!form.currentState!.validate()) return;
                        final saved = await context.read<CaseCubit>().setPrice(
                          current.id,
                          Money.parse(total.text),
                        );
                        if (saved && context.mounted) Navigator.pop(context);
                      },
                    ),
                    NcButton(
                      label: context.t('cancel'),
                      secondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
