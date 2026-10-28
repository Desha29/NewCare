import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/app_localizations.dart';
import '../core/storage/string_store.dart';
import '../core/theme/app_theme.dart';
import '../features/workspace/data/repositories/workspace_repository.dart';
import '../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../features/cases/presentation/cubit/case_cubit.dart';
import '../features/shifts/presentation/cubit/shift_cubit.dart';
import '../features/drawer/presentation/cubit/drawer_cubit.dart';
import '../features/management/presentation/cubit/management_cubit.dart';
import 'cubit/app_cubit.dart';
import 'workspace_shell.dart';

class NewCareApp extends StatelessWidget {
  const NewCareApp({super.key, required this.repository, required this.store});
  final WorkspaceRepository repository;
  final StringStore store;
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<WorkspaceRepository>.value(value: repository),
      RepositoryProvider<StringStore>.value(value: store),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AppCubit(store, configured: repository.current.setupDone)
                ..loadLocale(),
        ),
        BlocProvider(create: (_) => WorkspaceCubit(repository)),
        BlocProvider(create: (_) => CaseCubit(repository)),
        BlocProvider(create: (_) => ShiftCubit(repository)),
        BlocProvider(create: (_) => DrawerCubit(repository)),
        BlocProvider(create: (_) => ManagementCubit(repository)),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) => MaterialApp(
          title: 'NewCare',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WorkspaceShell(),
        ),
      ),
    ),
  );
}
