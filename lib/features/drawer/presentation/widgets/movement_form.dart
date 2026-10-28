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
  const MovementForm({super.key, this.advance = false});
  final bool advance;
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
    return Form(
      key: form,
      child: NcCard(
        title: context.t(widget.advance ? 'newAdvance' : 'cashMovement'),
        children: [
          const OperationError<DrawerCubit>(),
          if (saved)
            NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
          if (shift == null)
            NcNotice(title: context.t('noOpenShift'), tone: NoticeTone.warning),
          if (!widget.advance)
            NcSelect<CashKind>(
              label: context.t('movementKind'),
              value: kind,
              items: [
                for (final k in [CashKind.income, CashKind.expense])
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
          NcField(
            label: '${context.t('reason')} *',
            controller: reason,
            validator: (v) => v == null || v.trim().isEmpty
                ? context.t('requiredField')
                : null,
          ),
          NcSelect<String>(
            label: context.t('recordedBy'),
            value: staff,
            items: data.staff
                .where((n) => shift?.memberIds.contains(n.id) ?? false)
                .map((n) => DropdownMenuItem(value: n.id, child: Text(n.name)))
                .toList(),
            onChanged: (v) => setState(() => staff = v),
            validator: (v) => v == null ? context.t('requiredField') : null,
          ),
          NcButton(
            label: context.t(widget.advance ? 'saveAdvance' : 'saveMovement'),
            onPressed: shift == null
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    final movement = CashMovement(
                      id: operationId,
                      shiftId: shift.id,
                      staffId: staff!,
                      kind: widget.advance ? CashKind.advance : kind,
                      amountMinor: Money.parse(amount.text),
                      reason: reason.text.trim(),
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
