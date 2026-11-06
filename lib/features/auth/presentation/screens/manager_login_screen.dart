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
import '../../data/models/manager_choice.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});
  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final password = TextEditingController();
  final username = TextEditingController();
  String? error;
  bool loading = false;
  late Future<List<ManagerChoice>> managers;

  @override
  void initState() {
    super.initState();
    username.text = AppCubit.defaultLocalUsername;
    final authentication = context.read<AppCubit>().authentication;
    managers = authentication?.listManagers() ?? Future.value(const []);
  }

  @override
  void dispose() {
    password.dispose();
    username.dispose();
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
            if (error != null)
              NcNotice(title: context.t(error!), tone: NoticeTone.danger),
            if (context.read<AppCubit>().cloudAuthentication)
              FutureBuilder<List<ManagerChoice>>(
                future: managers,
                builder: (context, snapshot) {
                  final choices = snapshot.data ?? const <ManagerChoice>[];
                  if (choices.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.t('chooseManager')),
                      const SizedBox(height: 8),
                      for (final manager in choices)
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            key: ValueKey('manager-login-${manager.id}'),
                            leading: const Icon(Icons.manage_accounts_outlined),
                            title: Text(manager.name),
                            subtitle: Text(manager.username),
                            selected: username.text == manager.username,
                            trailing: username.text == manager.username
                                ? const Icon(Icons.check_circle_outline)
                                : null,
                            onTap: loading
                                ? null
                                : () => setState(() {
                                    username.text = manager.username;
                                    password.clear();
                                    error = null;
                                  }),
                          ),
                        ),
                    ],
                  );
                },
              ),
            NcField(
              label: context.t('username'),
              controller: username,
              enabled: !loading,
              onChanged: (_) => setState(() {}),
            ),
            if (!context.read<AppCubit>().cloudAuthentication)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: Text(AppCubit.defaultLocalUsername),
                  subtitle: Text(context.t('managerAccount')),
                  selected: username.text == AppCubit.defaultLocalUsername,
                  onTap: loading
                      ? null
                      : () => setState(
                          () => username.text = AppCubit.defaultLocalUsername,
                        ),
                ),
              ),
            NcField(
              label: context.t('password'),
              controller: password,
              obscure: true,
              enabled: !loading,
            ),
            NcButton(
              label: context.t('signIn'),
              busy: loading,
              onPressed: loading
                  ? null
                  : () async {
                      setState(() {
                        loading = true;
                        error = null;
                      });
                      final app = context.read<AppCubit>();
                      final accepted = await app.signIn(
                        username.text,
                        password.text,
                      );
                      if (!mounted) return;
                      setState(() {
                        loading = false;
                        error = accepted ? null : app.loginError;
                      });
                    },
            ),
          ],
        ),
        if (!context.watch<AppCubit>().cloudAuthentication)
          NcNotice(
            title: context.t('previewGate'),
            detail: context.watch<AppCubit>().state.customPassword
                ? null
                : '${context.t('previewPassword')} · ${context.t('previewUsername')}',
            tone: NoticeTone.warning,
          ),
        if (context.watch<AppCubit>().cloudAuthentication)
          NcNotice(
            title: context.t('offlineLoginHelp'),
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
