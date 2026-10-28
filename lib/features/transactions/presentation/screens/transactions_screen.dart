import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../widgets/new_transaction_dialog.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/transaction_entry.dart';
import '../widgets/transaction_filters.dart';
import '../widgets/transaction_table.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String query = '', kind = 'all', payment = 'all', member = 'all';
  @override
  Widget build(BuildContext context) {
    context.watch<AppCubit>();
    final data = context.watch<WorkspaceCubit>().state;
    final range = PeriodFilter.range(context);
    final rows = TransactionEntry.forRange(data, range.start, range.end).where((
      r,
    ) {
      final nurse =
          data.staff.where((n) => n.id == r.staffId).firstOrNull?.name ?? '';
      return (kind == 'all' || r.kind.name == kind) &&
          (payment == 'all' || r.payment.name == payment) &&
          (member == 'all' || r.staffId == member) &&
          '${r.description} $nurse ${r.id}'.toLowerCase().contains(
            query.trim().toLowerCase(),
          );
    }).toList();
    final totals = TransactionTotals(rows);
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NcButton(
            label: context.t('newTransaction'),
            icon: Icons.add,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const NewTransactionDialog(),
            ),
          ),
        ),
        NcMetricGrid(
          items: [
            MetricValue(context.t('cashIn'), context.money(totals.cashIn)),
            MetricValue(context.t('cashOut'), context.money(totals.cashOut)),
            MetricValue(
              context.t('walletReceipts'),
              context.money(totals.walletIn),
            ),
            MetricValue(
              context.t('netCashFlow'),
              context.money(totals.netCash),
            ),
          ],
        ),
        TransactionFilters(
          staff: data.staff,
          kind: kind,
          payment: payment,
          member: member,
          onQuery: (v) => setState(() => query = v),
          onKind: (v) => setState(() => kind = v),
          onPayment: (v) => setState(() => payment = v),
          onMember: (v) => setState(() => member = v),
        ),
        NcNotice(title: context.t('transactionTotalsNote')),
        NcBarChart(
          title: context.t('transactionBreakdown'),
          subtitle: context.t('currency'),
          values: [
            for (final k in TransactionKind.values)
              ChartValue(context.t(k.name), totals.amountFor(k) / 100),
          ],
        ),
        TransactionTable(rows: rows, staff: data.staff),
      ],
    );
  }
}
