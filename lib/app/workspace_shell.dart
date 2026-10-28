import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/localization_extensions.dart';
import '../core/responsive/app_breakpoints.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/center_clock.dart';
import '../core/utils/formatters.dart';
import '../features/workspace/presentation/cubit/workspace_cubit.dart';
import 'cubit/app_cubit.dart';
import 'navigation/app_page.dart';
import 'navigation/page_builder.dart';
import 'widgets/workspace_header.dart';
import 'widgets/workspace_sidebar.dart';
import 'widgets/workspace_bottom_navigation.dart';
import 'widgets/workspace_navigation_rail.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({super.key});
  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  final scaffold = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (context.watch<AppCubit>().state.page == AppPage.login) {
      return buildPage(AppPage.login);
    }
    final app = context.watch<AppCubit>().state;
    final data = context.watch<WorkspaceCubit>().state;
    final size = AppBreakpoints.of(context);
    final compact = size == WindowClass.compact;
    final rail = !compact && MediaQuery.sizeOf(context).width < 960;
    final shift = data.activeShift;
    final duration = shift == null
        ? Duration.zero
        : CenterClock.now().difference(shift.openedAt);
    final subtitle = app.page == AppPage.activeShift && shift != null
        ? '${context.t('openedAt')} ${context.time(shift.openedAt)} · ${context.t('duration')} ${duration.isNegative ? '00:00' : '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}'}'
        : context.t(app.page.isManager ? 'managerArea' : 'nurseArea');
    return Scaffold(
      key: scaffold,
      drawer: compact
          ? Drawer(
              child: WorkspaceSidebar(
                onSelected: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      bottomNavigationBar: compact ? const WorkspaceBottomNavigation() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!compact)
              SizedBox(
                width: rail
                    ? 80
                    : size == WindowClass.expanded
                    ? 224
                    : 188,
                child: rail
                    ? const WorkspaceNavigationRail()
                    : const WorkspaceSidebar(),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(compact ? 20 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WorkspaceHeader(
                      compact: compact,
                      onMenu: () => scaffold.currentState?.openDrawer(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.t(app.page.labelKey),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          context.t('localPreview'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        key: ValueKey(app.page),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: buildPage(app.page),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
