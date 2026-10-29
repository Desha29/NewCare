import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../widgets/shift_nursing_grid.dart';
import '../widgets/recent_cases_table.dart';
import '../../../cases/presentation/widgets/add_case_dialog.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import 'start_shift_screen.dart';

class ActiveShiftScreen extends StatelessWidget {
  const ActiveShiftScreen({super.key, this.localQueue = false});
  final bool localQueue;
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final shift = data.activeShift;
    final app = context.read<AppCubit>();
    if (shift == null) return const StartShiftScreen();
    final records = data.cases.where((c) => c.shiftId == shift.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return NcPageColumn(
      children: [
        if (localQueue)
          NcNotice(
            title: context.t('offlineNote'),
            detail: context.t('pendingSync'),
            tone: NoticeTone.warning,
          ),
        NcCard(
          title: context.t('currentNursing'),
          children: [
            const ShiftNursingGrid(),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => app.navigate(AppPage.joinShift),
                icon: const Icon(Icons.person_add_alt, size: 17),
                label: Text(context.t('joinShift')),
              ),
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NcButton(
            label: context.t('addCase'),
            icon: Icons.add,
            onPressed: () async {
              final saved = await AddCaseDialog.open(context);
              if (saved == true && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(context.t('savedNote'))));
              }
            },
          ),
        ),
        NcCard(
          title: '${context.t('lastCases')} · ${records.length}',
          children: [
            RecentCasesTable(
              records: records.take(5).toList(),
              workspace: data,
            ),
            TextButton(
              onPressed: () => app.navigate(AppPage.shiftCases),
              child: Text(context.t('viewHistory')),
            ),
          ],
        ),
      ],
    );
  }
}
