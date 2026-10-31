import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../core/storage/preferences_store.dart';
import '../core/storage/open_app_store.dart';
import '../core/storage/string_store.dart';
import '../core/theme/app_theme.dart';
import '../features/launch/presentation/screens/splash_screen.dart';
import '../features/workspace/data/repositories/local_workspace_repository.dart';
import 'newcare_app.dart';
import '../features/auth/data/repositories/cloud_runtime.dart';
import '../features/auth/presentation/screens/cloud_setup_screen.dart';
import '../features/staff/data/models/nursing_member.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<(StringStore, LocalWorkspaceRepository, CloudRuntime?)>
  initialize;
  bool animationComplete = false;
  @override
  void initState() {
    super.initState();
    initialize = _load();
  }

  Future<(StringStore, LocalWorkspaceRepository, CloudRuntime?)> _load() async {
    final legacy = PreferencesStore(await SharedPreferences.getInstance());
    final store = await openAppStore(legacy);
    final cloud = await CloudRuntime.open(store);
    final repository = LocalWorkspaceRepository(store, seedDemo: cloud == null);
    await repository.initialize();
    return (store, repository, cloud);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: initialize,
    builder: (context, snapshot) {
      Widget child;
      if (snapshot.hasData && animationComplete) {
        final (store, repository, cloud) = snapshot.data!;
        if (cloud != null &&
            (cloud.centerId == null || !cloud.localSetupComplete)) {
          child = MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: CloudSetupScreen(
              runtime: cloud,
              onReady: (identity) async {
                await repository.addStaff(
                  NursingMember(
                    id: identity.id,
                    name: identity.name,
                    isManager: true,
                  ),
                );
                await repository.saveSettings(
                  managerName: identity.name,
                  managerEmail: identity.email,
                  setupDone: true,
                );
                await cloud.completeLocalSetup();
                if (mounted) {
                  setState(
                    () => initialize = Future.value((store, repository, cloud)),
                  );
                }
              },
            ),
          );
        } else {
          child = NewCareApp(
            key: const ValueKey('workspace'),
            repository: repository,
            store: store,
            authentication: cloud?.authentication,
          );
        }
      } else {
        child = MaterialApp(
          key: ValueKey(snapshot.hasError ? 'startup-error' : 'splash'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: snapshot.hasError
              ? Builder(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context).storageFailed),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() {
                              animationComplete = false;
                              initialize = _load();
                            }),
                            child: Text(AppLocalizations.of(context).retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SplashScreen(
                  onCompleted: () {
                    if (mounted) setState(() => animationComplete = true);
                  },
                ),
        );
      }
      return AnimatedSwitcher(
        duration:
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        child: child,
      );
    },
  );
}
