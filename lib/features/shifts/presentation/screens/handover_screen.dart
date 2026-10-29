import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/shift_cubit.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key, this.matched = false});
  final bool matched;
  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  final counted = TextEditingController(), reason = TextEditingController();
  final form = GlobalKey<FormState>();
  String? member;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = context.read<WorkspaceCubit>().state;
    final preferred = context.read<AppCubit>().state.staffId;
    member ??= data.staff.any((n) => n.active && n.id == preferred)
        ? preferred
        : null;
  }

  @override
  void dispose() {
    counted.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final expected = data.shifts.isEmpty
        ? data.openingMinor
        : data.shifts.last.closingCountedMinor ??
              data.expectedCash(data.shifts.last);
    int? amount;
    try {
      amount = Money.parse(counted.text);
    } catch (_) {}
    final difference = amount == null ? null : amount - expected;
    return NcPageColumn(
      maxWidth: 860,
      children: [
        const OperationError<ShiftCubit>(),
        if (data.shifts.isNotEmpty && data.shifts.last.closedAt != null)
          NcCard(
            title: context.t('lastShiftClosed'),
            children: [
              Text(
                '${context.t('started')}: ${context.date(data.shifts.last.openedAt)} · ${context.time(data.shifts.last.openedAt)}',
              ),
              Text(
                '${context.t('ended')}: ${context.date(data.shifts.last.closedAt!)} · ${context.time(data.shifts.last.closedAt!)}',
              ),
              Text(
                '${context.t('drawerCheckedBy')}: ${data.staff.where((n) => n.id == data.shifts.last.drawerCheckedBy).firstOrNull?.name ?? '—'}',
              ),
              NcStatusBadge(data.shifts.last.drawerStatusKey),
            ],
          ),
        if (data.activeShift != null)
          NcNotice(
            title: context.t('shiftAlreadyOpen'),
            tone: NoticeTone.warning,
          ),
        Form(
          key: form,
          child: NcCard(
            title: context.t('handover'),
            children: [
              NcSelect<String>(
                label: context.t('selectStaff'),
                value: member,
                items: data.staff
                    .where((n) => n.active)
                    .map(
                      (n) => DropdownMenuItem(
                        value: n.id,
                        child: Text(
                          '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => member = v),
                validator: (v) => v == null ? context.t('requiredField') : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.t('expectedCash')),
                trailing: Text(
                  context.money(expected),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              NcField(
                label: context.t('countedCash'),
                controller: counted,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  try {
                    Money.parse(v ?? '');
                    return null;
                  } catch (_) {
                    return context.t('invalidAmount');
                  }
                },
              ),
              if (difference != null)
                NcNotice(
                  title:
                      '${context.t('difference')}: ${context.money(difference)}',
                  detail: context.t(
                    difference == 0 ? 'balancedNote' : 'varianceNote',
                  ),
                  tone: difference == 0
                      ? NoticeTone.success
                      : NoticeTone.warning,
                ),
              if (difference != null && difference != 0)
                NcField(
                  label: context.t('differenceReason'),
                  controller: reason,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? context.t('reasonRequired')
                      : null,
                ),
            ],
          ),
        ),
        NcNotice(title: context.t('handoverNote')),
        NcButton(
          label: context.t('confirmHandover'),
          onPressed: data.activeShift != null
              ? null
              : () async {
                  if (!form.currentState!.validate()) return;
                  final success = await context.read<ShiftCubit>().start(
                    member!,
                    Money.parse(counted.text),
                    reason: reason.text,
                  );
                  if (success && context.mounted) {
                    context.read<AppCubit>().selectStaff(member!);
                    context.read<AppCubit>().navigate(AppPage.activeShift);
                  }
                },
        ),
      ],
    );
  }
}
