import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class ManagerShiftsScreen extends StatelessWidget {
  const ManagerShiftsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    context.watch<AppCubit>();
    context.watch<WorkspaceCubit>();
    final data = context.read<WorkspaceCubit>().state;
    final range = PeriodFilter.range(context);
    final shifts = data.shifts
        .where(
          (s) =>
              !s.openedAt.isBefore(CenterClock.dayStart(range.start)) &&
              s.openedAt.isBefore(CenterClock.dayAfter(range.end)),
        )
        .toList();
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        NcBarChart(
          title: context.t('caseCount'),
          values: shifts.reversed
              .take(5)
              .map(
                (s) => ChartValue(
                  context.time(s.openedAt),
                  data.cases.where((c) => c.shiftId == s.id).length.toDouble(),
                ),
              )
              .toList(),
        ),
        NcCard(
          title: context.t('shifts'),
          children: [
            NcAdaptiveTable(
              headers: [
                context.t('started'),
                context.t('status'),
                context.t('cases'),
                context.t('expectedCash'),
              ],
              rows: shifts.reversed
                  .map(
                    (s) => [
                      context.date(s.openedAt),
                      context.t(s.isOpen ? 'open' : 'closed'),
                      '${data.cases.where((c) => c.shiftId == s.id).length}',
                      context.money(data.expectedCash(s)),
                    ],
                  )
                  .toList(),
              emptyLabel: context.t('noResults'),
            ),
          ],
        ),
      ],
    );
  }
}
