import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_status_badge.dart';
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
  });
  final WorkspaceSnapshot workspace;
  final bool outside;
  final TextEditingController title, address, phone, supplies;
  final String? staffId, procedureId;
  final ValueChanged<String?> onStaff, onProcedure;
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (outside) ...[
          NcField(
            label: '${context.t('address')} *',
            controller: address,
            hint: context.t('addressHint'),
            lines: 2,
            validator: (v) => v == null || v.trim().isEmpty
                ? context.t('addressRequired')
                : null,
          ),
          const SizedBox(height: 16),
          NcField(
            label: context.t('phoneOptional'),
            controller: phone,
            hint: context.t('phoneHint'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
        ],
        NcSelect<String>(
          label: '${context.t('caseOwner')} *',
          value: staffId,
          items: workspace.staff
              .where(
                (n) =>
                    n.active &&
                    (workspace.activeShift?.memberIds.contains(n.id) ?? false),
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
        const SizedBox(height: 16),
        NcField(
          label: '${context.t('caseTitle')} *',
          controller: title,
          hint: context.t('titleHint'),
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        const SizedBox(height: 16),
        NcSelect<String>(
          label: '${context.t('procedure')} *',
          value: procedureId,
          items: workspace.procedures
              .where((p) => p.active)
              .map(
                (p) =>
                    DropdownMenuItem(value: p.id, child: Text(p.name(locale))),
              )
              .toList(),
          onChanged: onProcedure,
          validator: (v) => v == null ? context.t('requiredField') : null,
        ),
        const SizedBox(height: 16),
        NcField(
          label: context.t('supplies'),
          controller: supplies,
          hint: context.t('supplyHint'),
          lines: 2,
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
  });
  final TextEditingController amount;
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethod;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      NcField(
        label: '${context.t('amount')} *',
        controller: amount,
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
      const SizedBox(height: 16),
      Text(
        context.t('paymentMethod'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 10,
        children: [
          for (final p in PaymentMethod.values)
            ChoiceChip(
              label: Text(
                context.t(p.name),
                style: TextStyle(
                  color: NcStatusBadge.colors(p.name).$2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selectedColor: NcStatusBadge.colors(p.name).$1,
              backgroundColor: NcStatusBadge.colors(p.name).$1
                  .withValues(alpha: .5),
              selected: method == p,
              onSelected: (_) => onMethod(p),
            ),
        ],
      ),
    ],
  );
}
