import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_staff_tile.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class StartShiftScreen extends StatelessWidget {
  const StartShiftScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final app = context.watch<AppCubit>();
    return NcPageColumn(
      maxWidth: 800,
      children: [
        if (data.activeShift != null)
          NcNotice(title: context.t('shiftAlreadyOpen')),
        NcCard(
          title: context.t('chooseStarter'),
          children: [
            for (final member in data.staff.where((n) => n.active))
              NcStaffTile(
                member: member,
                selected: app.state.staffId == member.id,
                onTap: () => app.selectStaff(member.id),
              ),
          ],
        ),
        NcNotice(title: context.t('handoverNote')),
        NcButton(
          label: context.t(
            data.activeShift != null ? 'returnShift' : 'receiveDrawer',
          ),
          onPressed: () => app.navigate(
            data.activeShift != null ? AppPage.activeShift : AppPage.handover,
          ),
        ),
      ],
    );
  }
}
