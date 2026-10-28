import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../management/presentation/widgets/record_actions.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../data/models/transaction_entry.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({super.key, required this.rows, required this.staff});
  final List<TransactionEntry> rows;
  final List<NursingMember> staff;
  @override
  Widget build(BuildContext context) => NcCard(
    title: '${context.t('transactions')} · ${rows.length}',
    children: [
      NcAdaptiveTable(
        cellBuilder: (row, column, value) =>
            column == 4 ? NcStatusBadge(rows[row].payment.name) : Text(value),
        headers: [
          context.t('dateAndTime'),
          context.t('reason'),
          context.t('movementKind'),
          context.t('nursing'),
          context.t('paymentMethod'),
          context.t('amount'),
        ],
        rows: rows.map((r) {
          final member = staff.where((n) => n.id == r.staffId).firstOrNull;
          return [
            '${context.date(r.at)} · ${context.time(r.at)}',
            r.description,
            context.t(r.kind.name),
            '${member?.name ?? r.staffId}${member?.isManager == true ? ' · ${context.t('manager')}' : ''}',
            context.t(r.payment.name),
            '${r.incoming ? '+' : '−'} ${context.money(r.amountMinor)}',
          ];
        }).toList(),
        emptyLabel: context.t('noResults'),
        actions: (i) => RecordActions(kind: rows[i].sourceKind, id: rows[i].id),
      ),
    ],
  );
}
