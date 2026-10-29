import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_auth_layout.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../launch/presentation/widgets/animated_brand_mark.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});
  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final password = TextEditingController(), email = TextEditingController();
  bool error = false, loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      email.text = context.read<WorkspaceCubit>().state.managerEmail;
    }
  }

  @override
  void dispose() {
    password.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NcAuthLayout(
    child: NcPageColumn(
      children: [
        NcCard(
          children: [
            const Center(
              child: AnimatedBrandMark(
                animation: AlwaysStoppedAnimation(1),
                diameter: 104,
              ),
            ),
            Text(
              context.t('login'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              context.t('signInSubtitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (error)
              NcNotice(
                title: context.t('wrongPassword'),
                tone: NoticeTone.danger,
              ),
            NcField(
              label: context.t('email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
            ),
            NcField(
              label: context.t('password'),
              controller: password,
              obscure: true,
            ),
            NcButton(
              label: context.t('signIn'),
              onPressed: () {
                if (!context.read<AppCubit>().unlock(password.text)) {
                  setState(() => error = true);
                }
              },
            ),
          ],
        ),
        NcNotice(
          title: context.t('previewGate'),
          detail: context.watch<AppCubit>().state.customPassword
              ? null
              : context.t('previewPassword'),
          tone: NoticeTone.warning,
        ),
        NcButton(
          label: context.t('returnNursing'),
          secondary: true,
          onPressed: () =>
              context.read<AppCubit>().navigate(AppPage.activeShift),
        ),
        if (!context.watch<WorkspaceCubit>().state.setupDone)
          TextButton(
            onPressed: () => context.read<AppCubit>().navigate(AppPage.setup),
            child: Text(context.t('showSetup')),
          ),
      ],
    ),
  );
}
