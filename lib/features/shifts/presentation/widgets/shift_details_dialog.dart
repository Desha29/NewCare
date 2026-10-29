import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import 'recent_cases_table.dart';

class ShiftDetailsDialog extends StatelessWidget {
  const ShiftDetailsDialog({
    super.key,
    required this.shiftId,
    this.embedded = false,
  });
  final bool embedded;
  final String shiftId;
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final shift = data.shifts.firstWhere((s) => s.id == shiftId);
    final checker = data.staff
        .where((n) => n.id == shift.drawerCheckedBy)
        .firstOrNull;
    final cases = data.cases.where((c) => c.shiftId == shiftId).toList();
    final movements = data.movements
        .where((m) => m.shiftId == shiftId)
        .toList();
    final panel = Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1000,
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.t('shiftDetails'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: context.t('close'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  '${context.t('started')}: ${context.date(shift.openedAt)} · ${context.time(shift.openedAt)}',
                ),
                Text(
                  '${context.t('ended')}: ${shift.closedAt == null ? context.t('shiftOpen') : '${context.date(shift.closedAt!)} · ${context.time(shift.closedAt!)}'}',
                ),
                Text(
                  '${context.t('drawerCheckedBy')}: ${checker?.name ?? '—'}',
                ),
                const SizedBox(height: 12),
                NcStatusBadge(shift.drawerStatusKey),
                const SizedBox(height: 12),
                NcCard(
                  title: context.t('drawerReview'),
                  children: [
                    Text(
                      '${context.t('openingCash')}: ${context.money(shift.openingMinor)}',
                    ),
                    Text(
                      '${context.t('expectedCash')}: ${context.money(shift.closingExpectedMinor ?? data.expectedCash(shift))}',
                    ),
                    Text(
                      '${context.t('countedCash')}: ${shift.closingCountedMinor == null ? '—' : context.money(shift.closingCountedMinor!)}',
                    ),
                    if (shift.closingDifferenceMinor != null)
                      NcSignedMoney(shift.closingDifferenceMinor!),
                    if (shift.closingDifferenceReason.isNotEmpty)
                      Text(shift.closingDifferenceReason),
                  ],
                ),
                const SizedBox(height: 16),
                Text(context.t('cases')),
                const SizedBox(height: 8),
                RecentCasesTable(records: cases, workspace: data),
                const SizedBox(height: 16),
                Text(context.t('cashMovement')),
                for (final m in movements)
                  ListTile(
                    title: Text(m.reason),
                    subtitle: Text(context.t(m.kind.name)),
                    trailing: NcSignedMoney(m.signedMinor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return embedded ? (panel.child! as ConstrainedBox).child! : panel;
  }
}
