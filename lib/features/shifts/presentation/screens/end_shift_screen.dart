import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/shift_cubit.dart';

class EndShiftScreen extends StatefulWidget {
  const EndShiftScreen({super.key});
  @override
  State<EndShiftScreen> createState() => _EndShiftScreenState();
}

class _EndShiftScreenState extends State<EndShiftScreen> {
  final form = GlobalKey<FormState>();
  final counted = TextEditingController(),
      reason = TextEditingController(),
      note = TextEditingController();
  String? checker;
  int? reviewedExpected;
  String? reviewedShiftId;
  bool confirmed = false;
  @override
  void dispose() {
    counted.dispose();
    reason.dispose();
    note.dispose();
    super.dispose();
  }

  void invalidate() => setState(() => confirmed = false);
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state,
        shift = data.activeShift;
    if (shift == null) return NcEmpty(message: context.t('noOpenToClose'));
    final expected = data.expectedCash(shift);
    int? amount;
    try {
      amount = Money.parse(counted.text);
    } catch (_) {}
    final difference = amount == null ? null : amount - expected;
    final members = data.staff
        .where((n) => n.active && shift.memberIds.contains(n.id))
        .toList();
    final validChecker = members.any((n) => n.id == checker) ? checker : null;
    final ready =
        confirmed &&
        reviewedShiftId == shift.id &&
        reviewedExpected == expected &&
        validChecker != null &&
        amount != null;
    return NcPageColumn(
      maxWidth: 860,
      children: [
        const OperationError<ShiftCubit>(),
        NcNotice(
          title: context.t('checkDrawerFirst'),
          detail: context.t('checkDrawerExplanation'),
        ),
        NcCard(
          title: context.t('shiftTiming'),
          children: [
            Text(
              '${context.t('started')}: ${context.date(shift.openedAt)} · ${context.time(shift.openedAt)}',
            ),
            Text('${context.t('ended')}: ${context.t('shiftOpen')}'),
            Text(
              '${context.t('cases')}: ${data.cases.where((c) => c.shiftId == shift.id).length}',
            ),
          ],
        ),
        Form(
          key: form,
          child: NcCard(
            title: context.t('drawerReview'),
            children: [
              NcSelect<String>(
                label: context.t('drawerCheckedBy'),
                value: validChecker,
                items: members
                    .map(
                      (n) => DropdownMenuItem(
                        value: n.id,
                        child: Text(
                          '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  checker = v;
                  invalidate();
                },
                validator: (v) => v == null ? context.t('requiredField') : null,
              ),
              Text('${context.t('expectedCash')}: ${context.money(expected)}'),
              NcField(
                label: context.t('countedCash'),
                controller: counted,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => invalidate(),
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
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    NcStatusBadge(
                      difference == 0
                          ? 'drawerMatched'
                          : difference < 0
                          ? 'drawerShortage'
                          : 'drawerExcess',
                    ),
                    NcSignedMoney(difference),
                  ],
                ),
              if (difference != null && difference != 0)
                NcField(
                  label: context.t('differenceReason'),
                  controller: reason,
                  onChanged: (_) => invalidate(),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.t('reasonRequired')
                      : null,
                ),
              NcField(
                label: context.t('handoverNotes'),
                controller: note,
                lines: 2,
              ),
              NcButton(
                label: context.t('confirmDrawerReview'),
                secondary: ready,
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  setState(() {
                    reviewedExpected = expected;
                    reviewedShiftId = shift.id;
                    confirmed = true;
                  });
                },
              ),
            ],
          ),
        ),
        if (confirmed && !ready)
          NcNotice(title: context.t('drawerChanged'), tone: NoticeTone.warning),
        if (ready) ...[
          NcNotice(
            title: context.t('drawerReviewDone'),
            tone: NoticeTone.success,
          ),
          NcButton(
            label: context.t('finishShift'),
            icon: Icons.lock_outline,
            busy: context.watch<ShiftCubit>().state.busy,
            onPressed: () async {
              if (await context.read<ShiftCubit>().end(
                    note.text,
                    countedMinor: amount!,
                    checkedBy: validChecker,
                    verifiedExpectedMinor: reviewedExpected!,
                    differenceReason: reason.text.trim(),
                  ) &&
                  context.mounted) {
                context.read<AppCubit>().navigate(AppPage.startShift);
              }
            },
          ),
        ],
      ],
    );
  }
}
