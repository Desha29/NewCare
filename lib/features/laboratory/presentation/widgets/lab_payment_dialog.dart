import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_tabs.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/lab_order.dart';
import '../../data/models/lab_payment.dart';
import '../cubit/laboratory_cubit.dart';

class LabPaymentDialog extends StatefulWidget {
  const LabPaymentDialog({super.key, required this.order, this.onSaved});
  final LabOrder order;
  final VoidCallback? onSaved;

  @override
  State<LabPaymentDialog> createState() => _LabPaymentDialogState();
}

class _LabPaymentDialogState extends State<LabPaymentDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController amountController;
  PaymentMethod method = PaymentMethod.cash;
  String? staffId;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final activeStaff = data.staff.where((s) => s.active).toList();
    staffId ??= activeStaff.firstOrNull?.id;

    final paidMinor = data.paidForLab(widget.order);
    final remainingMinor = widget.order.totalMinor - paidMinor;
    final remainingEgp = remainingMinor / 100;

    if (amountController.text.isEmpty && remainingMinor > 0) {
      amountController.text = remainingEgp.toStringAsFixed(0);
    }

    return Form(
      key: form,
      child: NcCard(
        title: context.t('collectLabPayment'),
        children: [
          const OperationError<LaboratoryCubit>(),
          Text(
            '${widget.order.patientName} (${widget.order.patientAge} ${context.t('${widget.order.ageUnit}Unit')})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${context.t('labTotal')}: ${(widget.order.totalMinor / 100).toStringAsFixed(2)}'),
              Text('${context.t('labRemaining')}: ${remainingEgp.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(height: 20),
          NcField(
            label: context.t('paymentAmount'),
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.t('requiredField');
              final parsed = double.tryParse(v);
              if (parsed == null || parsed <= 0) return context.t('invalidAmount');
              if ((parsed * 100).round() > remainingMinor) {
                return context.t('invalidPaymentAmount');
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          NcTabs<PaymentMethod>(
            selected: method,
            maxWidth: null,
            items: [
              NcTabItem(
                value: PaymentMethod.cash,
                label: context.t('cash'),
                icon: Icons.payments_outlined,
              ),
              NcTabItem(
                value: PaymentMethod.wallet,
                label: context.t('wallet'),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
            onChanged: (m) => setState(() => method = m),
          ),
          const SizedBox(height: 16),
          NcButton(
            label: context.t('save'),
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              if (staffId == null) return;
              final amountEgp = double.parse(amountController.text.trim());
              final amountMinor = (amountEgp * 100).round();

              final payment = LabPayment(
                id: const Uuid().v4(),
                orderId: widget.order.id,
                amountMinor: amountMinor,
                method: method,
                staffId: staffId!,
                createdAt: DateTime.now(),
              );

              final success =
                  await context.read<LaboratoryCubit>().addPayment(payment);
              if (success && mounted) {
                widget.onSaved?.call();
              }
            },
          ),
        ],
      ),
    );
  }
}

