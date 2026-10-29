import '../navigation/navigation_label.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nc_logo.dart';
import '../cubit/app_cubit.dart';
import '../navigation/app_page.dart';
import 'workspace_sidebar.dart';

class WorkspaceNavigationRail extends StatelessWidget {
  const WorkspaceNavigationRail({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final manager = state.page.isManager && state.managerUnlocked;
    final pages = manager ? managerNavigation : nurseNavigation;
    return ColoredBox(
      color: AppColors.navyDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            const NcLogo(size: 48, wordmark: false),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final page in pages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Tooltip(
                        message: context.pageLabel(page),
                        child: Material(
                          color:
                              (state.page == page ||
                                  page == AppPage.shiftCases &&
                                      state.page.isCaseBook)
                              ? Colors.white.withValues(alpha: .15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: IconButton(
                            onPressed: () =>
                                context.read<AppCubit>().navigate(page),
                            icon: Icon(
                              pageIcon(page),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.t(manager ? 'lockManager' : 'login'),
              onPressed: () {
                if (manager) {
                  context.read<AppCubit>().lock();
                } else {
                  context.read<AppCubit>().navigate(AppPage.overview);
                }
              },
              icon: const Icon(
                Icons.lock_outline,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
