import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/managed_record_kind.dart';
import 'record_actions.dart';

class SalaryTable extends StatelessWidget {
  const SalaryTable({super.key});
  @override
  Widget build(BuildContext context) {
    final members = context
        .watch<WorkspaceCubit>()
        .state
        .staff
        .where((n) => n.active)
        .toList();
    final summary = summaryFor(context);
    return NcCard(
      title: context.t('salaryRegister'),
      children: [
        NcAdaptiveTable(
          headers: [
            context.t('nursing'),
            context.t('monthlySalary'),
            context.t('advanceTotal'),
            context.t('awardsTotal'),
            context.t('salaryAfterAdvances'),
          ],
          rows: members.map((n) {
            final advance = summary.movements
                .where((m) => m.kind == CashKind.advance && m.staffId == n.id)
                .fold<int>(0, (s, m) => s + m.amountMinor);
            return [
              '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
              context.money(n.salaryMinor),
              context.money(advance),
              context.money(
                summary.movements
                    .where((m) => m.kind == CashKind.award && m.staffId == n.id)
                    .fold<int>(0, (s, m) => s + m.amountMinor),
              ),
              context.money(n.salaryMinor - advance),
            ];
          }).toList(),
          emptyLabel: context.t('noResults'),
          actions: (i) =>
              RecordActions(kind: ManagedRecordKind.nursing, id: members[i].id),
        ),
      ],
    );
  }
}
