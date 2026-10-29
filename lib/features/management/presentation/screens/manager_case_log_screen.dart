import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../cases/presentation/screens/case_history_screen.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class ManagerCaseLogScreen extends StatelessWidget {
  const ManagerCaseLogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final summary = summaryFor(context);
    final data = context.watch<WorkspaceCubit>().state;
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        const CaseHistoryScreen(manager: true),
        NcBarChart(
          title: context.t('cases'),
          values: data.procedures
              .take(5)
              .map(
                (p) => ChartValue(
                  p.name(Localizations.localeOf(context).languageCode),
                  summary.cases
                      .where((c) => c.effectiveProcedureIds.contains(p.id))
                      .length
                      .toDouble(),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
