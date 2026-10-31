import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/operational_day.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/operational_day_summary.dart';

class OperationalDayHistory extends StatelessWidget {
  const OperationalDayHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final today = OperationalDay.today();

    // Collect the past 7 operational days
    final days = <OperationalDay>[];
    var current = today;
    for (int i = 0; i < 7; i++) {
      days.add(current);
      current = current.previous;
    }

    final summaries =
        days.map((d) => OperationalDaySummary.forDay(data, d)).toList();

    return NcCard(
      title: context.t('operationalDayHistory'),
      children: [
        if (summaries.isEmpty)
          NcEmpty(message: context.t('emptyCatalogue'))
        else
          NcAdaptiveTable(
            headers: [
              context.t('operationalDay'),
              context.t('dailyNetCash'),
              context.t('dailyWallet'),
              context.t('handover'),
            ],
            emptyLabel: context.t('emptyCatalogue'),
            rows: List.generate(summaries.length, (i) => List.filled(4, '')),
            cellBuilder: (rowIdx, colIdx, _) {
              final s = summaries[rowIdx];
              if (colIdx == 0) {
                final d = s.day.start;
                final dateStr =
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} (08:00)';
                return Text(
                  dateStr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                );
              }
              if (colIdx == 1) {
                return Text(
                  context.money(s.netCashMinor),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: s.netCashMinor < 0 ? Colors.red : Colors.green,
                  ),
                );
              }
              if (colIdx == 2) {
                return Text(
                  context.money(s.walletMinor),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              }
              return Text('${s.handovers.length}');
            },
          ),
      ],
    );
  }
}
