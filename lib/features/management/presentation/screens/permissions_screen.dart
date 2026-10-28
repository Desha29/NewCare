import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/manager_profile_editor.dart';
import '../widgets/management_form_dialog.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    return NcPageColumn(
      maxWidth: 900,
      children: [
        NcCard(
          title: context.t('managerArea'),
          children: [
            Text(data.managerName),
            Text(data.managerEmail),
            NcButton(
              label: context.t('edit'),
              icon: Icons.edit_outlined,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogContext) => ManagerProfileEditor(
                  onSaved: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
        NcCard(
          title: context.t('accessLevels'),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(context.t('nursing')),
              subtitle: Text(context.t('nursingAccess')),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(context.t('manager')),
              subtitle: Text(context.t('managerAccess')),
            ),
          ],
        ),
        NcNotice(title: context.t('previewGate'), tone: NoticeTone.warning),
      ],
    );
  }
}
