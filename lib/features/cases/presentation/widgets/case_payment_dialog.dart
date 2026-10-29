import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/case_record.dart';
import '../../data/models/case_payment.dart';
import '../cubit/case_cubit.dart';
import 'case_form_fields.dart';

class CasePaymentDialog extends StatefulWidget {
  const CasePaymentDialog({super.key, required this.caseId});
  final String caseId;
  static Future<void> open(BuildContext context, String id) => showDialog<void>(
    context: context,
    builder: (_) => CasePaymentDialog(caseId: id),
  );
  @override
  State<CasePaymentDialog> createState() => _CasePaymentDialogState();
}

class _CasePaymentDialogState extends State<CasePaymentDialog> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  final operationId = const Uuid().v4();
  PaymentMethod method = PaymentMethod.cash;
  String? staff;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final record = data.cases.where((c) => c.id == widget.caseId).firstOrNull;
    if (record == null) return const SizedBox.shrink();
    final remaining = data.remainingFor(record);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: NcCard(
              title: context.t('receivePayment'),
              children: [
                Text(
                  record.location == CaseLocation.outside
                      ? record.address
                      : record.title,
                ),
                Text(
                  '${context.t('remainingAmount')}: ${context.money(remaining)}',
                ),
                const OperationError<CaseCubit>(),
                NcSelect<String>(
                  label: context.t('recordedBy'),
                  value: staff,
                  items: [
                    for (final n in data.staff.where((n) => n.active))
                      DropdownMenuItem(
                        value: n.id,
                        child: Text(
                          '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => staff = v),
                  validator: (v) =>
                      v == null ? context.t('requiredField') : null,
                ),
                PaymentFields(
                  amount: amount,
                  method: method,
                  onMethod: (v) => setState(() => method = v),
                  amountLabel: context.t('paymentAmount'),
                  amountValidator: (v) {
                    try {
                      final value = Money.parse(v ?? '');
                      return value <= 0 || value > remaining
                          ? context.t('invalidPaymentAmount')
                          : null;
                    } catch (_) {
                      return context.t('invalidAmount');
                    }
                  },
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    NcButton(
                      label: context.t('savePayment'),
                      busy: context.watch<CaseCubit>().state.busy,
                      onPressed: () async {
                        if (!form.currentState!.validate()) return;
                        final saved = await context.read<CaseCubit>().receive(
                          CasePayment(
                            id: operationId,
                            caseId: record.id,
                            staffId: staff!,
                            amountMinor: Money.parse(amount.text),
                            method: method,
                            paidAt: CenterClock.now(),
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
          ),
        ),
      ),
    );
  }
}
