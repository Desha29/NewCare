import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import 'case_payment_dialog.dart';
import 'case_price_dialog.dart';

class CaseDetailsDialog extends StatelessWidget {
  const CaseDetailsDialog({super.key, required this.caseId});
  final String caseId;

  static Future<void> open(BuildContext context, String caseId) =>
      showDialog<void>(
        context: context,
        builder: (_) => CaseDetailsDialog(caseId: caseId),
      );

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final record = data.cases.where((c) => c.id == caseId).firstOrNull;

    if (record == null) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NcEmpty(message: context.t('noResults')),
              const SizedBox(height: 12),
              NcButton(
                label: context.t('close'),
                secondary: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    final staff = data.staff.where((n) => n.id == record.staffId).firstOrNull;
    final proc = data.procedures
        .where((p) => p.id == record.procedureId)
        .firstOrNull;
    final remaining = data.remainingFor(record);
    final paid = data.paidFor(record);

    final rows = <String, String>{
      context.t(
        'caseOwner',
      ): '${staff?.name ?? ''}${staff?.isManager ?? false ? ' · ${context.t('manager')}' : ''}',
      context.t('procedure'):
          proc?.name(Localizations.localeOf(context).languageCode) ??
          record.procedureId,
      context.t('usedSupplies'): record.stockUsages.isNotEmpty
          ? record.stockUsages
                .map((u) => '${u.name} × ${u.quantity}')
                .join('، ')
          : (record.supplies.isNotEmpty
                ? record.supplies.join('، ')
                : context.t('noSuppliesUsed')),
      context.t('agreedPrice'): context.money(record.invoiceMinor),
      context.t('paidTotal'): context.money(paid),
      context.t('remainingAmount'): context.money(remaining),
      context.t('paymentMethod'): context.t(record.payment.name),
      context.t(
        'time',
      ): '${context.date(record.createdAt)} · ${context.time(record.createdAt)}',
      if (record.address.isNotEmpty) context.t('address'): record.address,
      if (record.phone.isNotEmpty) context.t('phoneOptional'): record.phone,
    };

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            NcStatusBadge(record.location.name),
                            NcStatusBadge(record.payment.name),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: context.t('close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Dialog Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Details List
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final e in rows.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            e.key ==
                                                    context.t(
                                                      'remainingAmount',
                                                    ) &&
                                                remaining > 0
                                            ? AppColors.warning
                                            : AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.key != rows.keys.last)
                              const Divider(height: 10, thickness: 0.5),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment History Section
                    NcCard(
                      title: context.t('paymentHistory'),
                      padding: 14,
                      children: [
                        NcButton(
                          label: context.t('editCasePrice'),
                          icon: Icons.edit_outlined,
                          secondary: true,
                          onPressed: () =>
                              CasePriceDialog.open(context, record),
                        ),
                        if (record.amountMinor > 0)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              context.t('initialPayment'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${context.date(record.createdAt)} · ${context.time(record.createdAt)} · ${context.t(record.payment.name)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            trailing: NcSignedMoney(record.amountMinor),
                          ),
                        for (final p in data.payments.where(
                          (p) => p.caseId == record.id,
                        ))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              data.staff
                                      .where((n) => n.id == p.staffId)
                                      .firstOrNull
                                      ?.name ??
                                  '',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${context.date(p.paidAt)} · ${context.time(p.paidAt)} · ${context.t(p.method.name)}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            trailing: NcSignedMoney(p.amountMinor),
                          ),
                        if (remaining > 0) ...[
                          const SizedBox(height: 8),
                          NcButton(
                            label: context.t('receivePayment'),
                            icon: Icons.add_card,
                            onPressed: () =>
                                CasePaymentDialog.open(context, record.id),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Dialog Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: NcButton(
                  label: context.t('close'),
                  secondary: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
