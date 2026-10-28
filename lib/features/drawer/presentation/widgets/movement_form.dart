import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/cash_movement.dart';
import '../cubit/drawer_cubit.dart';

class MovementForm extends StatefulWidget {
  const MovementForm({
    super.key,
    this.advance = false,
    this.allowAdvances = false,
    this.managerMode = false,
    this.allowIncome = true,
    this.award = false,
  });
  final bool advance, allowAdvances, managerMode, allowIncome, award;
  @override
  State<MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<MovementForm> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(), reason = TextEditingController();
  String? staff;
  CashKind kind = CashKind.expense;
  bool saved = false;
  String operationId = const Uuid().v4();
  @override
  void dispose() {
    amount.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final shift = data.activeShift;
    final effectiveKind = widget.award
        ? CashKind.award
        : widget.advance
        ? CashKind.advance
        : kind;
    final staffPayment =
        effectiveKind == CashKind.advance || effectiveKind == CashKind.award;
    final members = data.staff
        .where(
          (n) =>
              n.active &&
              ((widget.managerMode && staffPayment) ||
                  (shift?.memberIds.contains(n.id) ?? false)),
        )
        .toList();
    final selectedStaff = members.any((n) => n.id == staff) ? staff : null;
    return Form(
      key: form,
      child: NcCard(
        title: context.t(
          widget.award
              ? 'newAward'
              : widget.advance
              ? 'newAdvance'
              : 'cashMovement',
        ),
        children: [
          const OperationError<DrawerCubit>(),
          if (saved)
            NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
          if (shift == null)
            NcNotice(title: context.t('noOpenShift'), tone: NoticeTone.warning),
          if (!widget.advance && !widget.award)
            NcSelect<CashKind>(
              label: context.t('movementKind'),
              value: kind,
              items: [
                for (final k in [
                  if (widget.allowIncome) CashKind.income,
                  CashKind.expense,
                  if (widget.allowAdvances) CashKind.advance,
                  if (widget.managerMode) CashKind.award,
                ])
                  DropdownMenuItem(value: k, child: Text(context.t(k.name))),
              ],
              onChanged: (v) => setState(() => kind = v!),
            ),
          NcField(
            label: '${context.t('amount')} *',
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              try {
                if (Money.parse(v ?? '') <= 0) {
                  return context.t('invalidAmount');
                }
                return null;
              } catch (_) {
                return context.t('invalidAmount');
              }
            },
          ),
          if (!staffPayment)
            NcField(
              label: '${context.t('reason')} *',
              controller: reason,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.t('requiredField')
                  : null,
            ),
          NcSelect<String>(
            label: context.t(staffPayment ? 'nursing' : 'recordedBy'),
            value: selectedStaff,
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
            onChanged: (v) => setState(() => staff = v),
            validator: (v) => v == null ? context.t('requiredField') : null,
          ),
          NcButton(
            label: context.t(
              widget.award
                  ? 'saveAward'
                  : widget.advance
                  ? 'saveAdvance'
                  : 'saveMovement',
            ),
            onPressed: shift == null
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    final movement = CashMovement(
                      id: operationId,
                      shiftId: shift.id,
                      staffId: selectedStaff!,
                      kind: effectiveKind,
                      amountMinor: Money.parse(amount.text),
                      reason: staffPayment
                          ? context.t(effectiveKind.name)
                          : reason.text.trim(),
                      createdAt: CenterClock.now(),
                    );
                    if (await context.read<DrawerCubit>().save(movement) &&
                        context.mounted) {
                      setState(() {
                        saved = true;
                        amount.clear();
                        reason.clear();
                        operationId = const Uuid().v4();
                      });
                    }
                  },
          ),
        ],
      ),
    );
  }
}
