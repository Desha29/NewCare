import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../analytics/data/models/report_summary.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../data/managed_record_kind.dart';
import 'record_actions.dart';

class CashMovementsPanel extends StatelessWidget {
  const CashMovementsPanel({super.key, this.onlyAdvances = false});
  final bool onlyAdvances;
  @override
  Widget build(BuildContext context) {
    context.watch<AppCubit>();
    final data = context.watch<WorkspaceCubit>().state;
    final range = PeriodFilter.range(context);
    final rows = ReportSummary.forRange(data, range.start, range.end).movements
        .where((m) => !onlyAdvances || m.kind == CashKind.advance)
        .toList()
        .reversed
        .toList();
    return NcCard(
      title: context.t(onlyAdvances ? 'outstandingAdvances' : 'cashMovement'),
      children: [
        NcAdaptiveTable(
          headers: [
            context.t('reason'),
            context.t('recordedBy'),
            context.t('amount'),
            context.t('movementKind'),
          ],
          rows: rows
              .map(
                (m) => [
                  m.reason,
                  data.staff
                          .where((n) => n.id == m.staffId)
                          .firstOrNull
                          ?.name ??
                      m.staffId,
                  context.money(m.amountMinor),
                  context.t(m.kind.name),
                ],
              )
              .toList(),
          emptyLabel: context.t('noResults'),
          actions: (i) =>
              RecordActions(kind: ManagedRecordKind.movement, id: rows[i].id),
        ),
      ],
    );
  }
}
