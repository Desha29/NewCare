import 'transaction_labels.dart';
import '../../../../core/widgets/nc_detail_page.dart';

import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/nc_signed_money.dart';
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
        onRowTap: (i) => NcDetailPage.open(
          context,
          tag: 'transaction-${rows[i].sourceKind.name}-${rows[i].id}',
          title: transactionDescription(context, rows[i]),
          child: NcCard(
            children: [
              Text('${context.date(rows[i].at)} · ${context.time(rows[i].at)}'),
              Text(transactionCategory(context, rows[i])),
              Text(
                staff.where((n) => n.id == rows[i].staffId).firstOrNull?.name ??
                    rows[i].staffId,
              ),
              NcStatusBadge(rows[i].payment.name),
              NcSignedMoney(rows[i].signedMinor),
              RecordActions(kind: rows[i].sourceKind, id: rows[i].id),
            ],
          ),
        ),
        cellBuilder: (row, column, value) => column == 1
            ? NcHeroTitle(
                tag: 'transaction-${rows[row].sourceKind.name}-${rows[row].id}',
                title: value,
              )
            : column == 4
            ? NcStatusBadge(rows[row].payment.name)
            : column == 5
            ? NcSignedMoney(rows[row].signedMinor)
            : Text(value),
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
            transactionDescription(context, r),
            transactionCategory(context, r),
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
