import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_toast.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../management/presentation/cubit/management_cubit.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(text: AppCubit.defaultLocalPassword);
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcPageColumn(
      maxWidth: 800,
      children: [
        NcNotice(
          title: context.t('setupSteps'),
          detail: context.t('previewGate'),
        ),
        const OperationError<ManagementCubit>(),
        NcCard(
          title: context.t('setup'),
          children: [
            NcField(
              label: context.t('managerName'),
              controller: name,
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.t('requiredField')
                  : null,
            ),
            NcField(
              label: context.t('email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains('@')
                  ? context.t('requiredField')
                  : null,
            ),
            NcField(
              label: context.t('managerPassword'),
              controller: password,
              obscure: true,
              validator: (v) =>
                  (v?.length ?? 0) >= 8 ? null : context.t('passwordTooShort'),
            ),
          ],
        ),
        NcButton(
          label: context.t('createManager'),
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            final mgrName = name.text.trim();
            final mgrEmail = email.text.trim();
            final repo = context.read<WorkspaceRepository>();
            final cubit = context.read<ManagementCubit>();
            final app = context.read<AppCubit>();
            final passwordError = await app.setInitialPassword(password.text);
            if (passwordError != null) {
              if (context.mounted) {
                NcToast.show(
                  context,
                  message: context.t(passwordError),
                  tone: NcToastTone.error,
                );
              }
              return;
            }
            final existingMgr = repo.current.staff
                .where((s) => s.isManager)
                .firstOrNull;
            if (existingMgr == null) {
              await repo.addStaff(
                NursingMember(id: 'manager-1', name: mgrName, isManager: true),
              );
            }
            if (await cubit.settings(name: mgrName, email: mgrEmail) &&
                context.mounted) {
              app.navigate(AppPage.setupNursing);
            }
          },
        ),
      ],
    ),
  );
}
