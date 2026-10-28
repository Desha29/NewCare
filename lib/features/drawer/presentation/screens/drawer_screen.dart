import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/movement_form.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final shift = data.activeShift;
    final movements = data.movements
        .where((m) => m.shiftId == shift?.id)
        .toList();
    return NcPageColumn(
      maxWidth: 900,
      children: [
        const MovementForm(allowAdvances: true, allowIncome: false),
        NcNotice(
          title: context.t('shiftOnly'),
          detail: context.t('noFinancialAccess'),
        ),
        if (movements.isNotEmpty)
          NcCard(
            title: context.t('latestActivity'),
            children: [
              for (final m in movements.reversed.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.reason),
                  subtitle: Text(context.t(m.kind.name)),
                  trailing: Text(context.money(m.amountMinor)),
                ),
            ],
          ),
      ],
    );
  }
}
