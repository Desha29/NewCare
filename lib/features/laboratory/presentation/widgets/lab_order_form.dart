import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_tabs.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../../core/widgets/nc_toast.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/lab_order.dart';
import '../../data/models/lab_order_item.dart';
import '../../data/models/lab_payment.dart';
import '../cubit/laboratory_cubit.dart';

class LabOrderForm extends StatefulWidget {
  const LabOrderForm({super.key, this.onSaved});
  final VoidCallback? onSaved;

  @override
  State<LabOrderForm> createState() => _LabOrderFormState();
}

class _LabOrderFormState extends State<LabOrderForm> {
  final form = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final paidController = TextEditingController(text: '0');
  String ageUnit = 'year';
  String? staffId;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  final Set<String> selectedTestIds = {};
  String testSearch = '';

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final activeTests = data.labTests.where((t) => t.active).toList();
    final activeStaff = data.staff.where((s) => s.active).toList();

    staffId ??= activeStaff.firstOrNull?.id;

    final selectedTests = activeTests
        .where((t) => selectedTestIds.contains(t.id))
        .toList();
    final totalMinor = selectedTests.fold<int>(
      0,
      (sum, t) => sum + t.priceMinor,
    );
    final totalEgp = totalMinor / 100;

    final filteredTests = testSearch.isEmpty
        ? activeTests
        : activeTests
              .where((t) => t.name.toLowerCase().contains(testSearch))
              .toList();

    return Form(
      key: form,
      child: NcCard(
        title: context.t('newLabOrder'),
        padding: 14,
        children: [
          const OperationError<LaboratoryCubit>(),
          NcField(
            label: context.t('patientName'),
            hint: context.t('patientName'),
            controller: nameController,
            validator: (v) => v == null || v.trim().isEmpty
                ? context.t('requiredField')
                : null,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: NcField(
                  label: context.t('patientAge'),
                  hint: context.t('patientAge'),
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.t('requiredField');
                    }
                    final parsed = int.tryParse(v);
                    if (parsed == null || parsed < 0) {
                      return context.t('invalidAmount');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: ageUnit,
                  decoration: InputDecoration(
                    labelText: context.t('ageUnit'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'year',
                      child: Text(context.t('yearUnit')),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text(context.t('monthUnit')),
                    ),
                    DropdownMenuItem(
                      value: 'day',
                      child: Text(context.t('dayUnit')),
                    ),
                  ],
                  onChanged: (v) => setState(() => ageUnit = v ?? 'year'),
                ),
              ),
            ],
          ),
          if (activeStaff.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: staffId,
              decoration: InputDecoration(
                labelText: context.t('recordedBy'),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              items: [
                for (final s in activeStaff)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => staffId = v),
            ),
          // Lab Tests Section with Search & Compact Chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    context.t('selectLabTests'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (selectedTestIds.isNotEmpty)
                    Text(
                      '${selectedTestIds.length}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (activeTests.length > 3) ...[
                TextField(
                  decoration: InputDecoration(
                    hintText: context.t('search'),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    prefixIconConstraints: const BoxConstraints(minWidth: 32),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => testSearch = v.trim().toLowerCase()),
                ),
                const SizedBox(height: 6),
              ],
              if (activeTests.isEmpty)
                Text(
                  context.t('noLabTests'),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 110),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in filteredTests)
                          FilterChip(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              '${t.name} (${(t.priceMinor / 100).toStringAsFixed(0)} ${context.t('currency')})',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                              ),
                            ),
                            selected: selectedTestIds.contains(t.id),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedTestIds.add(t.id);
                                } else {
                                  selectedTestIds.remove(t.id);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Total & Payment Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('labTotal'),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${totalEgp.toStringAsFixed(2)} ${context.t('currency')}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: TextFormField(
                    controller: paidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.t('labPaidNow'),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '0') ?? 0;
                      if (parsed < 0) return context.t('invalidAmount');
                      if ((parsed * 100).round() > totalMinor) {
                        return context.t('invalidPaymentAmount');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          NcTabs<PaymentMethod>(
            selected: paymentMethod,
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
            onChanged: (method) => setState(() => paymentMethod = method),
          ),
          NcButton(
            label: context.t('save'),
            onPressed: () async {
              if (selectedTestIds.isEmpty) {
                NcToast.show(
                  context,
                  message: context.t('itemsRequired'),
                  tone: NcToastTone.warning,
                );
                return;
              }
              if (!form.currentState!.validate()) return;
              if (staffId == null) return;

              final orderId = const Uuid().v4();
              final orderItems = selectedTests
                  .map(
                    (t) => LabOrderItem(
                      testId: t.id,
                      name: t.name,
                      priceMinor: t.priceMinor,
                    ),
                  )
                  .toList();
              final age = int.parse(ageController.text.trim());
              final order = LabOrder(
                id: orderId,
                patientName: nameController.text.trim(),
                patientAge: age,
                ageUnit: ageUnit,
                staffId: staffId!,
                createdAt: DateTime.now(),
                items: orderItems,
              );

              final paidEgp = double.tryParse(paidController.text.trim()) ?? 0;
              final paidMinor = (paidEgp * 100).round();

              LabPayment? initialPayment;
              if (paidMinor > 0) {
                initialPayment = LabPayment(
                  id: const Uuid().v4(),
                  orderId: orderId,
                  amountMinor: paidMinor,
                  method: paymentMethod,
                  staffId: staffId!,
                  createdAt: DateTime.now(),
                );
              }

              final success = await context.read<LaboratoryCubit>().addOrder(
                order,
                initialPayment: initialPayment,
              );
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
