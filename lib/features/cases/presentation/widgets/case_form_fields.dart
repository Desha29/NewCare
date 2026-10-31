import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_tabs.dart';
import '../../data/models/case_record.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';

class CaseFormFields extends StatelessWidget {
  const CaseFormFields({
    super.key,
    required this.workspace,
    required this.outside,
    required this.title,
    required this.address,
    required this.phone,
    required this.supplies,
    required this.staffId,
    required this.procedureId,
    required this.onStaff,
    required this.onProcedure,
    this.procedurePicker,
    this.supplyPicker,
    this.memberIds,
    this.includeInactive = false,
    this.compact = false,
  });
  final WorkspaceSnapshot workspace;
  final bool outside;
  final TextEditingController title, address, phone, supplies;
  final String? staffId, procedureId;
  final ValueChanged<String?> onStaff, onProcedure;
  final Widget? procedurePicker, supplyPicker;
  final List<String>? memberIds;
  final bool includeInactive;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (outside) ...[
          LayoutBuilder(
            builder: (context, c) {
              final paired = compact && c.maxWidth >= 460;
              final addressField = NcField(
                label: '${context.t('address')} *',
                controller: address,
                hint: context.t('addressHint'),
                lines: paired ? 1 : 2,
                validator: (v) => v == null || v.trim().isEmpty
                    ? context.t('addressRequired')
                    : null,
              );
              final phoneField = NcField(
                label: context.t('phoneOptional'),
                controller: phone,
                hint: context.t('phoneHint'),
                keyboardType: TextInputType.phone,
              );
              return paired
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: addressField),
                        const SizedBox(width: 10),
                        Expanded(child: phoneField),
                      ],
                    )
                  : Column(
                      children: [
                        addressField,
                        SizedBox(height: compact ? 8 : 16),
                        phoneField,
                      ],
                    );
            },
          ),
          SizedBox(height: compact ? 8 : 16),
        ],
        NcSelect<String>(
          label: '${context.t('caseOwner')} *',
          value: staffId,
          items: workspace.staff
              .where(
                (n) =>
                    (includeInactive || n.active) &&
                    (memberIds == null || memberIds!.contains(n.id)),
              )
              .map(
                (n) => DropdownMenuItem(
                  value: n.id,
                  child: Text(
                    '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                  ),
                ),
              )
              .toList(),
          onChanged: onStaff,
          validator: (v) => v == null ? context.t('requiredField') : null,
        ),
        SizedBox(height: compact ? 8 : 16),
        procedurePicker ??
            NcSelect<String>(
              label: '${context.t('procedure')} *',
              value: procedureId,
              items: workspace.procedures
                  .where((p) => p.active)
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name(locale)),
                    ),
                  )
                  .toList(),
              onChanged: onProcedure,
              validator: (v) => v == null ? context.t('requiredField') : null,
            ),
      ],
    );
  }
}

class PaymentFields extends StatelessWidget {
  const PaymentFields({
    super.key,
    required this.amount,
    required this.method,
    required this.onMethod,
    this.amountLabel,
    this.amountValidator,
    this.leadingField,
    this.compact = false,
  });
  final TextEditingController amount;
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethod;
  final String? amountLabel;
  final Widget? leadingField;
  final bool compact;
  final String? Function(String?)? amountValidator;
  @override
  Widget build(BuildContext context) {
    final amountField = NcField(
      label: '${amountLabel ?? context.t('amount')} *',
      controller: amount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator:
          amountValidator ??
          (v) {
            try {
              Money.parse(v ?? '');
              return null;
            } catch (_) {
              return context.t('invalidAmount');
            }
          },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leadingField == null)
          amountField
        else
          LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 320
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leadingField!),
                      const SizedBox(width: 10),
                      Expanded(child: amountField),
                    ],
                  )
                : Column(
                    children: [
                      leadingField!,
                      const SizedBox(height: 8),
                      amountField,
                    ],
                  ),
          ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          context.t('paymentMethod'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: compact ? 4 : 8),
        NcTabs<PaymentMethod>(
          selected: method,
          maxWidth: compact ? 260 : 360,
          items: [
            for (final p in PaymentMethod.values)
              NcTabItem(
                value: p,
                label: context.t(p.name),
                icon: p == PaymentMethod.cash
                    ? Icons.payments_outlined
                    : Icons.account_balance_wallet_outlined,
              ),
          ],
          onChanged: onMethod,
        ),
      ],
    );
  }
}
