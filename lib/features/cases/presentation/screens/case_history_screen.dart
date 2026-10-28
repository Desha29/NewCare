import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/data/models/report_summary.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/case_record.dart';
import '../widgets/case_list.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key, this.manager = false});
  final bool manager;
  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  final search = TextEditingController();
  CaseLocation? location;
  PaymentMethod? payment;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppCubit>();
    final data = context.watch<WorkspaceCubit>().state;
    final range = PeriodFilter.range(context);
    final source = widget.manager
        ? ReportSummary.forRange(data, range.start, range.end).cases
        : data.cases.where((c) => c.shiftId == data.activeShift?.id);
    final query = search.text.toLowerCase();
    final records = source
        .where((c) {
          final member = data.staff.where((n) => n.id == c.staffId).firstOrNull;
          return (location == null || location == c.location) &&
              (payment == null || payment == c.payment) &&
              ('${c.title} ${member?.name ?? ''} ${c.address}')
                  .toLowerCase()
                  .contains(query);
        })
        .toList()
        .reversed
        .toList();
    return NcPageColumn(
      children: [
        NcField(
          label: context.t('search'),
          controller: search,
          onChanged: (_) => setState(() {}),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: Text(context.t('allTypes')),
              selected: location == null,
              onSelected: (_) => setState(() => location = null),
            ),
            for (final value in CaseLocation.values)
              ChoiceChip(
                label: Text(context.t(value.name)),
                selected: location == value,
                onSelected: (_) => setState(() => location = value),
              ),
            ChoiceChip(
              label: Text(context.t('paymentMethod')),
              selected: payment == null,
              onSelected: (_) => setState(() => payment = null),
            ),
            for (final value in PaymentMethod.values)
              ChoiceChip(
                label: Text(context.t(value.name)),
                selected: payment == value,
                onSelected: (_) => setState(() => payment = value),
              ),
          ],
        ),
        NcCard(
          title: '${context.t('cases')} · ${records.length}',
          children: [
            if (widget.manager && !AppBreakpoints.compact(context))
              NcAdaptiveTable(
                headers: [
                  context.t('caseTitle'),
                  context.t('caseOwner'),
                  context.t('amount'),
                  context.t('paymentMethod'),
                  context.t('time'),
                ],
                rows: records.map((c) {
                  final n = data.staff
                      .where((n) => n.id == c.staffId)
                      .firstOrNull;
                  return [
                    c.title,
                    '${n?.name ?? ''}${n?.isManager ?? false ? ' · ${context.t('manager')}' : ''}',
                    context.money(c.amountMinor),
                    context.t(c.payment.name),
                    context.time(c.createdAt),
                  ];
                }).toList(),
                emptyLabel: context.t('noResults'),
                onRowTap: (i) =>
                    context.read<AppCubit>().selectCase(records[i].id),
              )
            else
              CaseList(records: records, workspace: data),
          ],
        ),
      ],
    );
  }
}
