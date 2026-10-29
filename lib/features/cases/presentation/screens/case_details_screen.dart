import '../widgets/case_price_dialog.dart';
import '../widgets/case_payment_dialog.dart';
import '../../../../core/widgets/nc_signed_money.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class CaseDetailsScreen extends StatelessWidget {
  const CaseDetailsScreen({super.key, this.caseId, this.onBack});
  final String? caseId;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final id = caseId ?? context.watch<AppCubit>().state.caseId;
    final record = data.cases.where((c) => c.id == id).firstOrNull;
    if (record == null) return NcEmpty(message: context.t('noResults'));
    final staff = data.staff.where((n) => n.id == record.staffId).firstOrNull;
    final proc = data.procedures
        .where((p) => p.id == record.procedureId)
        .firstOrNull;
    final rows = <String, String>{
      context.t(
        'caseOwner',
      ): '${staff?.name ?? ''}${staff?.isManager ?? false ? ' · ${context.t('manager')}' : ''}',
      context.t('procedure'):
          proc?.name(Localizations.localeOf(context).languageCode) ??
          record.procedureId,
      context.t('agreedPrice'): context.money(record.invoiceMinor),
      context.t('paidTotal'): context.money(data.paidFor(record)),
      context.t('remainingAmount'): context.money(data.remainingFor(record)),
      context.t('paymentMethod'): context.t(record.payment.name),
      context.t(
        'time',
      ): '${context.date(record.createdAt)} · ${context.time(record.createdAt)}',
      if (record.address.isNotEmpty) context.t('address'): record.address,
      if (record.phone.isNotEmpty) context.t('phoneOptional'): record.phone,
    };
    return NcPageColumn(
      maxWidth: 900,
      children: [
        NcCard(
          title: record.title,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NcStatusBadge(record.location.name),
                NcStatusBadge(record.payment.name),
              ],
            ),
            for (final e in rows.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  e.key,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                subtitle: Text(e.value),
              ),
          ],
        ),
        NcCard(
          title: context.t('paymentHistory'),
          children: [
            NcButton(
              label: context.t('editCasePrice'),
              icon: Icons.edit_outlined,
              secondary: true,
              onPressed: () => CasePriceDialog.open(context, record),
            ),
            if (record.amountMinor > 0)
              ListTile(
                title: Text(context.t('initialPayment')),
                subtitle: Text(
                  '${context.date(record.createdAt)} · ${context.time(record.createdAt)} · ${context.t(record.payment.name)}',
                ),
                trailing: NcSignedMoney(record.amountMinor),
              ),
            for (final p in data.payments.where((p) => p.caseId == record.id))
              ListTile(
                title: Text(
                  data.staff
                          .where((n) => n.id == p.staffId)
                          .firstOrNull
                          ?.name ??
                      '',
                ),
                subtitle: Text(
                  '${context.date(p.paidAt)} · ${context.time(p.paidAt)} · ${context.t(p.method.name)}',
                ),
                trailing: NcSignedMoney(p.amountMinor),
              ),
            if (data.remainingFor(record) > 0)
              NcButton(
                label: context.t('receivePayment'),
                icon: Icons.add_card,
                onPressed: () => CasePaymentDialog.open(context, record.id),
              ),
          ],
        ),
        NcNotice(title: context.t('localSaved')),
        NcButton(
          label: context.t('back'),
          secondary: true,
          onPressed:
              onBack ??
              () => context.read<AppCubit>().navigate(AppPage.activeShift),
        ),
      ],
    );
  }
}
