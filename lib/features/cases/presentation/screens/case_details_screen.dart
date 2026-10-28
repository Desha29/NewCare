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
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class CaseDetailsScreen extends StatelessWidget {
  const CaseDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final id = context.watch<AppCubit>().state.caseId;
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
      context.t('supplies'): record.supplies.join('\n'),
      context.t('amount'): context.money(record.amountMinor),
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
        NcNotice(title: context.t('localSaved')),
        NcButton(
          label: context.t('returnShift'),
          secondary: true,
          onPressed: () =>
              context.read<AppCubit>().navigate(AppPage.activeShift),
        ),
      ],
    );
  }
}
