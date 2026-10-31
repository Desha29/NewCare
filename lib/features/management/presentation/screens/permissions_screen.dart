import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/manager_profile_editor.dart';
import '../widgets/management_form_dialog.dart';
import '../widgets/manager_password_editor.dart';
import '../widgets/navigation_labels_editor.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../widgets/manager_account_editor.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final app = context.watch<AppCubit>();
    return NcPageColumn(
      maxWidth: 900,
      children: [
        NcCard(
          title: context.t('managerArea'),
          children: [
            Text(app.managerIdentity?.name ?? data.managerName),
            Text(app.managerIdentity?.email ?? data.managerEmail),
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
        const ManagerPasswordEditor(),
        if (app.cloudAuthentication &&
            app.managerIdentity?.manageAccounts == true)
          NcCard(
            title: context.t('managerAccounts'),
            children: [
              Text(context.t('managerAccountsHelp')),
              NcButton(
                label: context.t('addManager'),
                icon: Icons.person_add_alt,
                onPressed: () => ManagementFormDialog.open(
                  context,
                  (dialogContext) => ManagerAccountEditor(
                    onSaved: () => Navigator.pop(dialogContext),
                  ),
                ),
              ),
            ],
          ),
        const NavigationLabelsEditor(),
      ],
    );
  }
}
