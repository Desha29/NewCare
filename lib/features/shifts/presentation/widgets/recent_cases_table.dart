import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';

class RecentCasesTable extends StatelessWidget {
  const RecentCasesTable({
    super.key,
    required this.records,
    required this.workspace,
  });
  final List<CaseRecord> records;
  final WorkspaceSnapshot workspace;
  @override
  Widget build(BuildContext context) => NcAdaptiveTable(
    alwaysTable: true,
    cellBuilder: (row, column, value) => column == 2
        ? NcStatusBadge(records[row].location.name)
        : column == 4
        ? NcStatusBadge(records[row].payment.name)
        : Text(value),
    headers: [
      context.t('caseTitle'),
      context.t('nursing'),
      context.t('caseType'),
      context.t('amount'),
      context.t('paymentMethod'),
      context.t('time'),
    ],
    rows: records.map((r) {
      final member = workspace.staff
          .where((n) => n.id == r.staffId)
          .firstOrNull;
      return [
        r.title,
        '${member?.name ?? r.staffId}${member?.isManager == true ? ' · ${context.t('manager')}' : ''}',
        context.t(r.location.name),
        context.money(r.amountMinor),
        context.t(r.payment.name),
        context.time(r.createdAt),
      ];
    }).toList(),
    emptyLabel: context.t('noCases'),
    onRowTap: (i) => context.read<AppCubit>().selectCase(records[i].id),
  );
}
