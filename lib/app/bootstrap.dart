import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../core/storage/preferences_store.dart';
import '../core/theme/app_theme.dart';
import '../features/workspace/data/repositories/local_workspace_repository.dart';
import 'newcare_app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<(PreferencesStore, LocalWorkspaceRepository)> initialize;
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialize,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final (store, repository) = snapshot.data!;
          return NewCareApp(repository: repository, store: store);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final strings = AppLocalizations.of(context);
              return Scaffold(
                body: Center(
                  child: snapshot.hasError
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(strings.storageFailed),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () =>
                                  setState(() => initialize = _load()),
                              child: Text(strings.retry),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
