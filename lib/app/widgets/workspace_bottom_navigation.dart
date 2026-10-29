import '../navigation/navigation_label.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/localization_extensions.dart';
import '../cubit/app_cubit.dart';
import '../navigation/app_page.dart';
import 'workspace_sidebar.dart';

class WorkspaceBottomNavigation extends StatelessWidget {
  const WorkspaceBottomNavigation({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final manager = state.page.isManager && state.managerUnlocked;
    final pages = manager
        ? [
            AppPage.overview,
            AppPage.reports,
            AppPage.nursing,
            AppPage.permissions,
          ]
        : [
            AppPage.activeShift,
            AppPage.shiftCases,
            AppPage.cashMovement,
            AppPage.login,
          ];
    final index = pages.indexOf(
      state.page.isCaseBook ? AppPage.shiftCases : state.page,
    );
    return NavigationBar(
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) => context.read<AppCubit>().navigate(pages[i]),
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final p in pages)
          NavigationDestination(
            icon: Icon(
              p == AppPage.login ? Icons.lock_outline : pageIcon(p),
              size: 20,
            ),
            label: p == AppPage.login
                ? context.t('manager')
                : context.pageLabel(p),
          ),
      ],
    );
  }
}
