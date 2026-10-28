import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/data/models/report_summary.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/case_record.dart';
import '../widgets/case_card_grid.dart';
import '../widgets/case_view_tabs.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../management/presentation/widgets/record_actions.dart';

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
  bool cards = true;
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
    final records = source.where((c) {
      final member = data.staff.where((n) => n.id == c.staffId).firstOrNull;
      return (location == null || location == c.location) &&
          (payment == null || payment == c.payment) &&
          ('${c.title} ${member?.name ?? ''} ${c.address}')
              .toLowerCase()
              .contains(query);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                label: Text(
                  context.t(value.name),
                  style: TextStyle(color: NcStatusBadge.colors(value.name).$2),
                ),
                selectedColor: NcStatusBadge.colors(value.name).$1,
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
                label: Text(
                  context.t(value.name),
                  style: TextStyle(color: NcStatusBadge.colors(value.name).$2),
                ),
                selectedColor: NcStatusBadge.colors(value.name).$1,
                selected: payment == value,
                onSelected: (_) => setState(() => payment = value),
              ),
          ],
        ),
        NcCard(
          title: '${context.t('cases')} · ${records.length}',
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CaseViewTabs(
                cards: cards,
                onChanged: (value) => setState(() => cards = value),
              ),
            ),
            if (!cards)
              NcAdaptiveTable(
                alwaysTable: true,
                cellBuilder: (row, column, value) => column == 2
                    ? NcStatusBadge(records[row].location.name)
                    : column == 4
                    ? NcStatusBadge(records[row].payment.name)
                    : Text(value),
                headers: [
                  context.t('caseTitle'),
                  context.t('caseOwner'),
                  context.t('caseType'),
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
                    context.t(c.location.name),
                    context.money(c.amountMinor),
                    context.t(c.payment.name),
                    context.time(c.createdAt),
                  ];
                }).toList(),
                emptyLabel: context.t('noResults'),
                actions: !widget.manager
                    ? null
                    : (i) => RecordActions(
                        kind: ManagedRecordKind.caseRecord,
                        id: records[i].id,
                      ),
                onRowTap: (i) =>
                    context.read<AppCubit>().selectCase(records[i].id),
              )
            else
              CaseCardGrid(
                records: records,
                workspace: data,
                editable: widget.manager,
              ),
          ],
        ),
      ],
    );
  }
}
