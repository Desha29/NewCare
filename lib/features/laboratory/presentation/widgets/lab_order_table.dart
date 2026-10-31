import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../management/presentation/widgets/management_form_dialog.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/lab_order.dart';
import '../cubit/laboratory_cubit.dart';
import 'lab_payment_dialog.dart';
import 'lab_result_dialog.dart';

class LabOrderTable extends StatelessWidget {
  const LabOrderTable({super.key, required this.orders});
  final List<LabOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return NcEmpty(message: context.t('noLabOrders'));
    }

    final data = context.watch<WorkspaceCubit>().state;
    final cubit = context.read<LaboratoryCubit>();

    return NcAdaptiveTable(
      headers: [
        context.t('patientName'),
        context.t('laboratory'),
        context.t('labTotal'),
        context.t('resultStatus'),
      ],
      emptyLabel: context.t('noLabOrders'),
      columnWidths: const [150, 200, 130, 170],
      rows: List.generate(orders.length, (i) => List.filled(4, '')),
      cellBuilder: (rowIdx, colIdx, _) {
        final order = orders[rowIdx];
        final paid = data.paidForLab(order);
        final remaining = order.totalMinor - paid;

        if (colIdx == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.patientName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${order.patientAge} ${context.t('${order.ageUnit}Unit')}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
            ],
          );
        }

        if (colIdx == 1) {
          return Text(
            order.items.map((i) => i.name).join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }

        if (colIdx == 2) {
          final totalStr = (order.totalMinor / 100).toStringAsFixed(2);
          final paidStr = (paid / 100).toStringAsFixed(2);
          final remStr = (remaining / 100).toStringAsFixed(2);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalStr ${context.t('currency')}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (remaining > 0)
                Text(
                  '${context.t('labRemaining')}: $remStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Text(
                  '${context.t('paid')}: $paidStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: order.received ? AppColors.tealLight : AppColors.warningBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                order.received
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top_outlined,
                size: 14,
                color: order.received ? AppColors.teal : AppColors.warning,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  order.received
                      ? context.t('resultReceived')
                      : context.t('resultPending'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: order.received ? AppColors.teal : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      actions: (rowIdx) {
        final order = orders[rowIdx];
        final paid = data.paidForLab(order);
        final remaining = order.totalMinor - paid;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remaining > 0)
              IconButton(
                icon: const Icon(Icons.payment, size: 20),
                tooltip: context.t('collectLabPayment'),
                onPressed: () => ManagementFormDialog.open(
                  context,
                  (dialogCtx) => BlocProvider.value(
                    value: cubit,
                    child: LabPaymentDialog(
                      order: order,
                      onSaved: () => Navigator.pop(dialogCtx),
                    ),
                  ),
                ),
              ),
            if (!order.received)
              IconButton(
                icon: const Icon(Icons.assignment_turned_in_outlined, size: 20),
                tooltip: context.t('markResultReceived'),
                onPressed: () => ManagementFormDialog.open(
                  context,
                  (dialogCtx) => BlocProvider.value(
                    value: cubit,
                    child: LabResultDialog(
                      order: order,
                      onSaved: () => Navigator.pop(dialogCtx),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
