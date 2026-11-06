import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../l10n/app_localizations.dart';
import '../core/storage/string_store.dart';
import '../core/theme/app_theme.dart';
import '../features/workspace/data/repositories/workspace_repository.dart';
import '../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../features/cases/presentation/cubit/case_cubit.dart';
import '../features/drawer/presentation/cubit/drawer_cubit.dart';
import '../features/management/presentation/cubit/management_cubit.dart';
import 'cubit/app_cubit.dart';
import 'workspace_shell.dart';
import '../features/auth/data/repositories/manager_auth_repository.dart';
import '../features/workspace/data/sources/manager_staff_projection.dart';
import '../features/sync/data/repositories/cloud_sync_service.dart';

class NewCareApp extends StatelessWidget {
  const NewCareApp({
    super.key,
    required this.repository,
    required this.store,
    this.authentication,
    this.syncService,
  });
  final WorkspaceRepository repository;
  final StringStore store;
  final ManagerAuthRepository? authentication;
  final CloudSyncService? syncService;
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<WorkspaceRepository>.value(value: repository),
      RepositoryProvider<StringStore>.value(value: store),
      RepositoryProvider<CloudSyncService?>.value(value: syncService),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppCubit(
            store,
            configured: repository.current.setupDone || authentication != null,
            authentication: authentication,
            onManagerVerified: (identity) =>
                ensureManagerStaff(repository, identity),
          )..loadLocale(),
        ),
        BlocProvider(create: (_) => WorkspaceCubit(repository)),
        BlocProvider(create: (_) => CaseCubit(repository)),
        BlocProvider(create: (_) => DrawerCubit(repository)),
        BlocProvider(create: (_) => ManagementCubit(repository)),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) => ToastificationWrapper(
          child: MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: state.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: WorkspaceShell(syncService: syncService),
          ),
        ),
      ),
    ),
  );
}
