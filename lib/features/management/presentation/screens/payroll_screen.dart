import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../drawer/presentation/widgets/movement_form.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../widgets/cash_movements_panel.dart';
import '../widgets/management_form_dialog.dart';
import '../widgets/salary_editor.dart';
import '../widgets/salary_table.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final summary = summaryFor(context);
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        NcActionRow(
          children: [
            NcButton(
              label: context.t('newAward'),
              icon: Icons.workspace_premium_outlined,
              secondary: true,
              onPressed: () => ManagementFormDialog.open(
                context,
                (_) => const MovementForm(award: true, managerMode: true),
              ),
            ),
            NcButton(
              label: context.t('setSalary'),
              icon: Icons.payments_outlined,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogContext) =>
                    SalaryEditor(onSaved: () => Navigator.pop(dialogContext)),
              ),
            ),
            NcButton(
              label: context.t('newAdvance'),
              icon: Icons.add,
              secondary: true,
              onPressed: () => ManagementFormDialog.open(
                context,
                (_) => const MovementForm(advance: true, managerMode: true),
              ),
            ),
          ],
        ),
        NcMetricGrid(
          items: [
            MetricValue(
              context.t('advanceTotal'),
              context.money(summary.advanceMinor),
            ),
            MetricValue(
              context.t('awardsTotal'),
              context.money(summary.awardMinor),
            ),
            MetricValue(
              context.t('monthlySalary'),
              context.money(
                data.staff
                    .where((n) => n.active)
                    .fold<int>(0, (s, n) => s + n.salaryMinor),
              ),
            ),
          ],
        ),
        NcBarChart(
          title: context.t('outstandingAdvances'),
          values: data.staff
              .take(5)
              .map(
                (n) => ChartValue(
                  n.name.split(' ').first,
                  summary.movements
                          .where(
                            (m) =>
                                m.kind == CashKind.advance && m.staffId == n.id,
                          )
                          .fold<int>(0, (s, m) => s + m.amountMinor) /
                      100,
                ),
              )
              .toList(),
        ),
        NcNotice(title: context.t('salaryNote')),
        const SalaryTable(),
        const CashMovementsPanel(onlyAdvances: true),
        NcNotice(title: context.t('advanceNote')),
      ],
    );
  }
}
