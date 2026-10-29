import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/drawer_handover.dart';
import '../cubit/drawer_cubit.dart';

class DrawerHandoverPanel extends StatefulWidget {
  const DrawerHandoverPanel({super.key});
  static Future<void> open(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const SingleChildScrollView(child: DrawerHandoverPanel()),
      ),
    ),
  );
  @override
  State<DrawerHandoverPanel> createState() => _DrawerHandoverPanelState();
}

class _DrawerHandoverPanelState extends State<DrawerHandoverPanel> {
  final form = GlobalKey<FormState>();
  final counted = TextEditingController(), note = TextEditingController();
  final id = const Uuid().v4();
  String? from, to;
  int? reviewedBalance;
  @override
  void dispose() {
    counted.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    // Freeze the displayed count baseline until the user explicitly refreshes it.
    reviewedBalance ??= data.drawerBalance;
    if (data.drawerHolder != null) from = data.drawerHolder;
    final stale = reviewedBalance != data.drawerBalance;
    final members = data.staff
        .where((n) => n.active || n.id == data.drawerHolder)
        .toList();
    final receivers = members.where((n) => n.active && n.id != from).toList();
    if (!receivers.any((n) => n.id == to)) to = null;
    final canConfirm = !stale && from != null && to != null && from != to;
    return Form(
      key: form,
      child: NcCard(
        title: context.t('drawerHandover'),
        children: [
          const OperationError<DrawerCubit>(),
          Text(
            context.t('drawerHandoverNote'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          NcSelect<String>(
            label: context.t('drawerFrom'),
            value: from,
            items: [
              for (final n in members.where(
                (n) => data.drawerHolder == null || n.id == data.drawerHolder,
              ))
                DropdownMenuItem(value: n.id, child: Text(n.name)),
            ],
            onChanged: (v) => setState(() {
              from = v;
              if (to == from) to = null;
            }),
            validator: (v) => v == null ? context.t('requiredField') : null,
          ),
          NcSelect<String>(
            label: context.t('drawerTo'),
            value: to,
            items: [
              for (final n in receivers)
                DropdownMenuItem(value: n.id, child: Text(n.name)),
            ],
            onChanged: (v) => setState(() => to = v),
            validator: (v) => v == null || v == from
                ? context.t('invalidHandoverStaff')
                : null,
          ),
          if (from != null && receivers.isEmpty)
            Text(
              context.t('noOtherDrawerReceiver'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Text(
            '${context.t('expectedCash')}: ${context.money(reviewedBalance!)}',
          ),
          if (stale) ...[
            Text(context.t('drawerChanged')),
            NcButton(
              label: context.t('refreshDrawer'),
              secondary: true,
              onPressed: () =>
                  setState(() => reviewedBalance = data.drawerBalance),
            ),
          ],
          NcField(
            label: context.t('countedCash'),
            controller: counted,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              try {
                Money.parse(v ?? '');
                return null;
              } catch (_) {
                return context.t('invalidAmount');
              }
            },
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: counted,
            builder: (context, value, _) {
              int amount;
              try {
                amount = Money.parse(value.text);
              } catch (_) {
                return const SizedBox.shrink();
              }
              final delta = amount - reviewedBalance!;
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  NcStatusBadge(
                    delta == 0
                        ? 'drawerMatched'
                        : delta < 0
                        ? 'drawerShortage'
                        : 'drawerExcess',
                  ),
                  NcSignedMoney(delta),
                ],
              );
            },
          ),
          NcField(
            label: context.t('handoverDifferenceReason'),
            controller: note,
            lines: 2,
            validator: (v) {
              try {
                return Money.parse(counted.text) != reviewedBalance &&
                        (v?.trim().isEmpty ?? true)
                    ? context.t('reasonRequired')
                    : null;
              } catch (_) {
                return null;
              }
            },
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              NcButton(
                label: context.t('confirmDrawerHandover'),
                busy: context.watch<DrawerCubit>().state.busy,
                onPressed: !canConfirm
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        final saved = await context
                            .read<DrawerCubit>()
                            .handover(
                              DrawerHandover(
                                id: id,
                                fromStaffId: from!,
                                toStaffId: to!,
                                expectedMinor: reviewedBalance!,
                                countedMinor: Money.parse(counted.text),
                                at: CenterClock.now(),
                                note: note.text.trim(),
                              ),
                            );
                        if (saved && context.mounted) Navigator.pop(context);
                      },
              ),
              NcButton(
                label: context.t('cancel'),
                secondary: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerHandoverHistory extends StatelessWidget {
  const DrawerHandoverHistory({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final rows = data.handovers.reversed.toList();
    String name(String id) =>
        data.staff.where((n) => n.id == id).firstOrNull?.name ?? id;
    return NcCard(
      title: context.t('drawerHandoverHistory'),
      children: [
        if (data.drawerHolder != null)
          Text('${context.t('drawerHolder')}: ${name(data.drawerHolder!)}'),
        NcAdaptiveTable(
          headers: [
            context.t('dateAndTime'),
            context.t('drawerFrom'),
            context.t('drawerTo'),
            context.t('expectedCash'),
            context.t('countedCash'),
            context.t('status'),
            context.t('difference'),
            context.t('notes'),
          ],
          rows: [
            for (final h in rows)
              [
                '${context.date(h.at)} · ${context.time(h.at)}',
                name(h.fromStaffId),
                name(h.toStaffId),
                context.money(h.expectedMinor),
                context.money(h.countedMinor),
                context.t(h.statusKey),
                context.money(h.differenceMinor),
                h.note,
              ],
          ],
          cellBuilder: (i, column, value) => column == 5
              ? NcStatusBadge(rows[i].statusKey)
              : column == 6
              ? NcSignedMoney(rows[i].differenceMinor)
              : Text(value),
          emptyLabel: context.t('noResults'),
        ),
      ],
    );
  }
}
