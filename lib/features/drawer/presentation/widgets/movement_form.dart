import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
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

enum OutgoingGroup { center, people }

enum PersonPaymentPurpose { advance, other, award }

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
  final amount = TextEditingController(),
      reason = TextEditingController(),
      recipient = TextEditingController();
  String? staff;
  OutgoingGroup group = OutgoingGroup.center;
  PersonPaymentPurpose purpose = PersonPaymentPurpose.other;
  bool incoming = false, otherPerson = false, saved = false;
  String operationId = const Uuid().v4();
  @override
  void dispose() {
    amount.dispose();
    reason.dispose();
    recipient.dispose();
    super.dispose();
  }

  Widget choice(
    BuildContext context,
    String key,
    bool selected,
    VoidCallback select, {
    IconData? icon,
  }) => ChoiceChip(
    label: Text(
      context.t(key),
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    avatar: icon == null ? null : Icon(icon, size: 18, color: AppColors.navy),
    selected: selected,
    selectedColor: AppColors.tealLight,
    onSelected: (_) => setState(() {
      saved = false;
      select();
    }),
  );

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final fixed = widget.advance || widget.award;
    final people = fixed || (!incoming && group == OutgoingGroup.people);
    final activePurpose = widget.award
        ? PersonPaymentPurpose.award
        : widget.advance
        ? PersonPaymentPurpose.advance
        : purpose;
    final external =
        people &&
        otherPerson &&
        !fixed &&
        activePurpose != PersonPaymentPurpose.award;
    final members = data.staff.where((n) => n.active).toList();
    final member = members.where((n) => n.id == staff).firstOrNull;
    final kind = incoming && !fixed
        ? CashKind.income
        : !people
        ? CashKind.expense
        : activePurpose == PersonPaymentPurpose.award
        ? CashKind.award
        : activePurpose == PersonPaymentPurpose.advance
        ? external
              ? CashKind.externalAdvance
              : CashKind.advance
        : CashKind.expense;
    final needsDescription =
        !people || activePurpose == PersonPaymentPurpose.other;
    final amountField = NcField(
      label: '${context.t('amount')} *',
      controller: amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        try {
          return Money.parse(v ?? '') <= 0 ? context.t('invalidAmount') : null;
        } catch (_) {
          return context.t('invalidAmount');
        }
      },
    );
    final description = NcField(
      label: context.t('outgoingDescription'),
      controller: reason,
      hint: context.t(
        incoming
            ? 'incomeDescriptionHint'
            : people
            ? 'personOutgoingHint'
            : 'centerOutgoingHint',
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? context.t('requiredField') : null,
    );
    return Form(
      key: form,
      child: NcCard(
        padding: 16,
        title: context.t(
          widget.award
              ? 'newAward'
              : widget.advance
              ? 'newAdvance'
              : incoming
              ? 'income'
              : 'recordOutgoing',
        ),
        children: [
          const OperationError<DrawerCubit>(),
          if (saved)
            NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
          if (widget.allowIncome && !fixed)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                choice(context, 'outgoings', !incoming, () {
                  incoming = false;
                  staff = null;
                }),
                choice(context, 'income', incoming, () {
                  incoming = true;
                  staff = null;
                }),
              ],
            ),
          if (!incoming && !fixed) ...[
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                choice(
                  context,
                  'centerExpense',
                  group == OutgoingGroup.center,
                  () {
                    group = OutgoingGroup.center;
                    staff = null;
                  },
                  icon: Icons.business_outlined,
                ),
                choice(
                  context,
                  'personOutgoings',
                  group == OutgoingGroup.people,
                  () {
                    group = OutgoingGroup.people;
                    staff = null;
                  },
                  icon: Icons.person_outline,
                ),
              ],
            ),
            Text(
              context.t(people ? 'personOutgoingHelp' : 'centerOutgoingHelp'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (people && !fixed) ...[
            Text(
              context.t('personPaymentPurpose'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                choice(
                  context,
                  'advance',
                  activePurpose == PersonPaymentPurpose.advance,
                  () => purpose = PersonPaymentPurpose.advance,
                ),
                choice(
                  context,
                  'otherPersonOutgoing',
                  activePurpose == PersonPaymentPurpose.other,
                  () => purpose = PersonPaymentPurpose.other,
                ),
                if (widget.managerMode)
                  choice(
                    context,
                    'award',
                    activePurpose == PersonPaymentPurpose.award,
                    () {
                      purpose = PersonPaymentPurpose.award;
                      otherPerson = false;
                      staff = null;
                    },
                  ),
              ],
            ),
            if (activePurpose != PersonPaymentPurpose.award)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  choice(context, 'nursing', !otherPerson, () {
                    otherPerson = false;
                    staff = null;
                  }),
                  choice(context, 'otherPerson', otherPerson, () {
                    otherPerson = true;
                    staff = null;
                  }),
                ],
              ),
          ],
          if (external)
            NcField(
              label: context.t('personName'),
              controller: recipient,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.t('recipientRequired')
                  : null,
            ),
          NcSelect<String>(
            label: context.t(
              people && !external ? 'personNursingRecipient' : 'recordedBy',
            ),
            value: member?.id,
            items: [
              for (final n in members)
                DropdownMenuItem(
                  value: n.id,
                  child: Text(
                    '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                  ),
                ),
            ],
            onChanged: (v) => setState(() => staff = v),
            validator: (v) => v == null ? context.t('requiredField') : null,
          ),
          LayoutBuilder(
            builder: (context, c) => needsDescription && c.maxWidth >= 600
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: amountField),
                      const SizedBox(width: 12),
                      Expanded(child: description),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      amountField,
                      if (needsDescription) ...[
                        const SizedBox(height: 12),
                        description,
                      ],
                    ],
                  ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NcButton(
              label: context.t(
                widget.award
                    ? 'saveAward'
                    : widget.advance
                    ? 'saveAdvance'
                    : incoming
                    ? 'saveMovement'
                    : 'saveOutgoing',
              ),
              busy: context.watch<DrawerCubit>().state.busy,
              icon: Icons.check,
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                final movement = CashMovement(
                  id: operationId,
                  shiftId: '',
                  staffId: member!.id,
                  kind: kind,
                  amountMinor: Money.parse(amount.text),
                  recipient: people
                      ? external
                            ? recipient.text.trim()
                            : member.name
                      : '',
                  reason: needsDescription
                      ? reason.text.trim()
                      : context.t(
                          activePurpose == PersonPaymentPurpose.award
                              ? 'award'
                              : 'advance',
                        ),
                  createdAt: CenterClock.now(),
                );
                if (await context.read<DrawerCubit>().save(movement) &&
                    context.mounted) {
                  setState(() {
                    saved = true;
                    amount.clear();
                    reason.clear();
                    recipient.clear();
                    operationId = const Uuid().v4();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
