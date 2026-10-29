import '../widgets/drawer_handover_button.dart';
import '../widgets/drawer_handover_panel.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../transactions/presentation/widgets/new_transaction_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../../../management/presentation/widgets/cash_movements_panel.dart';

class ManagerDrawerScreen extends StatelessWidget {
  const ManagerDrawerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final summary = summaryFor(context);
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            NcButton(
              label: context.t('newTransaction'),
              icon: Icons.add,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const NewTransactionDialog(),
              ),
            ),
          ],
        ),
        NcMetricGrid(
          items: [
            MetricValue(
              context.t('drawerBalance'),
              context.money(data.drawerBalance),
            ),
            MetricValue(
              context.t('cashRevenue'),
              context.money(summary.cashMinor),
            ),
            MetricValue(
              context.t('walletRevenue'),
              context.money(summary.walletMinor),
            ),
          ],
        ),
        DailyRevenueChart(summary: summary),
        const CashMovementsPanel(),
        const DrawerHandoverButton(),
        const DrawerHandoverHistory(),
      ],
    );
  }
}
