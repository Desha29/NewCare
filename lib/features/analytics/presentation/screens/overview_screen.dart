import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/analytics_sections.dart';
import '../widgets/period_filter.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final summary = summaryFor(context);
    final inside = summary.cases
        .where((c) => c.location == CaseLocation.inside)
        .length;
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        NcMetricGrid(
          items: [
            MetricValue(
              context.t('totalRevenue'),
              context.money(summary.revenueMinor),
            ),
            MetricValue(context.t('caseCount'), '${summary.cases.length}'),
            MetricValue(
              context.t('expenses'),
              context.money(summary.expenseMinor),
            ),
            MetricValue(
              context.t('expectedCash'),
              context.money(
                data.shifts.isEmpty
                    ? data.openingMinor
                    : data.expectedCash(data.shifts.last),
              ),
            ),
          ],
        ),
        DailyRevenueChart(summary: summary),
        NcCard(
          title: context.t('caseDistribution'),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('inside')),
              trailing: Text('$inside'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.t('outside')),
              trailing: Text('${summary.cases.length - inside}'),
            ),
          ],
        ),
        StaffCasesChart(summary: summary),
      ],
    );
  }
}
