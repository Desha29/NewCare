import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../core/storage/preferences_store.dart';
import '../core/theme/app_theme.dart';
import '../features/launch/presentation/screens/splash_screen.dart';
import '../features/workspace/data/repositories/local_workspace_repository.dart';
import 'newcare_app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<(PreferencesStore, LocalWorkspaceRepository)> initialize;
  bool animationComplete = false;
  @override
  void initState() {
    super.initState();
    initialize = _load();
  }

  Future<(PreferencesStore, LocalWorkspaceRepository)> _load() async {
    final store = PreferencesStore(await SharedPreferences.getInstance());
    final repository = LocalWorkspaceRepository(store);
    await repository.initialize();
    return (store, repository);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: initialize,
    builder: (context, snapshot) {
      Widget child;
      if (snapshot.hasData && animationComplete) {
        final (store, repository) = snapshot.data!;
        child = NewCareApp(
          key: const ValueKey('workspace'),
          repository: repository,
          store: store,
        );
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
