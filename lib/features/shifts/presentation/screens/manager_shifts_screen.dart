import '../../../../core/widgets/nc_detail_page.dart';

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
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../../core/widgets/nc_button.dart';
import '../widgets/shift_details_dialog.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../management/presentation/widgets/record_actions.dart';
import '../../../management/presentation/widgets/cash_movements_panel.dart';

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
              !s.archived &&
              !s.openedAt.isBefore(CenterClock.dayStart(range.start)) &&
              s.openedAt.isBefore(CenterClock.dayAfter(range.end)),
        )
        .toList();
    final rows = shifts.reversed.toList();
    return NcPageColumn(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NcButton(
            label: context.t('chooseDay'),
            icon: Icons.calendar_today_outlined,
            secondary: true,
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: CenterClock.now(),
              );
              if (date != null && context.mounted) {
                context.read<AppCubit>().setRange(
                  DateTimeRange(start: date, end: date),
                );
              }
            },
          ),
        ),
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
              onRowTap: (i) => NcDetailPage.open(
                context,
                tag: 'shift-${rows[i].id}',
                title:
                    '${context.date(rows[i].openedAt)} · ${context.time(rows[i].openedAt)}',
                child: ShiftDetailsDialog(shiftId: rows[i].id, embedded: true),
              ),
              cellBuilder: (row, column, value) => column == 0
                  ? NcHeroTitle(tag: 'shift-${rows[row].id}', title: value)
                  : column == 7
                  ? NcStatusBadge(rows[row].drawerStatusKey)
                  : column == 8 && rows[row].closingDifferenceMinor != null
                  ? NcSignedMoney(rows[row].closingDifferenceMinor!)
                  : Text(value),
              headers: [
                context.t('started'),
                context.t('ended'),
                context.t('drawerCheckedBy'),
                context.t('status'),
                context.t('cases'),
                context.t('expectedCash'),
                context.t('countedCash'),
                context.t('drawerReview'),
                context.t('difference'),
              ],
              rows: rows
                  .map(
                    (s) => [
                      '${context.date(s.openedAt)}\n${context.time(s.openedAt)}',
                      s.closedAt == null
                          ? '—'
                          : '${context.date(s.closedAt!)}\n${context.time(s.closedAt!)}',
                      data.staff
                              .where((n) => n.id == s.drawerCheckedBy)
                              .firstOrNull
                              ?.name ??
                          '—',
                      context.t(s.isOpen ? 'open' : 'closed'),
                      '${data.cases.where((c) => c.shiftId == s.id).length}',
                      context.money(
                        s.closingExpectedMinor ?? data.expectedCash(s),
                      ),
                      s.closingCountedMinor == null
                          ? '—'
                          : context.money(s.closingCountedMinor!),
                      context.t(s.drawerStatusKey),
                      s.closingDifferenceMinor == null
                          ? '—'
                          : context.money(s.closingDifferenceMinor!),
                    ],
                  )
                  .toList(),
              emptyLabel: context.t('noResults'),
              actions: (i) => RecordActions(
                kind: ManagedRecordKind.shift,
                id: shifts.reversed.toList()[i].id,
              ),
            ),
          ],
        ),
        const CashMovementsPanel(),
      ],
    );
  }
}
