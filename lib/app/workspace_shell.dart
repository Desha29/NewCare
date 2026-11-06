import 'navigation/navigation_label.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/localization_extensions.dart';
import '../core/responsive/app_breakpoints.dart';
import '../features/workspace/presentation/cubit/workspace_cubit.dart';
import 'cubit/app_cubit.dart';
import 'navigation/app_page.dart';
import 'navigation/page_builder.dart';
import 'widgets/workspace_header.dart';
import 'widgets/workspace_sidebar.dart';
import 'widgets/workspace_bottom_navigation.dart';
import 'widgets/workspace_navigation_rail.dart';
import '../features/sync/data/repositories/cloud_sync_service.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({super.key, this.syncService});
  final CloudSyncService? syncService;
  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  final scaffold = GlobalKey<ScaffoldState>();
  bool sidebarVisible = true;
  @override
  Widget build(BuildContext context) {
    if (context.watch<AppCubit>().state.page == AppPage.login) {
      return buildPage(AppPage.login);
    }
    final app = context.watch<AppCubit>().state;
    final controller = context.read<AppCubit>();
    final data = context.watch<WorkspaceCubit>().state;
    final storageLabel = controller.offlineManager
        ? 'offlineManagerSession'
        : controller.cloudAuthentication
        ? 'localDataSyncPending'
        : data.setupDone
        ? 'localSaved'
        : 'localPreview';
    final size = AppBreakpoints.of(context);
    final compact = size == WindowClass.compact;
    final rail = !compact && MediaQuery.sizeOf(context).width < 960;
    final displayedPage = app.page;
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
            if (!compact && sidebarVisible)
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
              key: const ValueKey('workspace-main'),
              child: Padding(
                padding: EdgeInsets.all(compact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WorkspaceHeader(
                      syncService: widget.syncService,
                      compact: compact,
                      navigationOpen: !compact && sidebarVisible,
                      title: context.pageLabel(displayedPage),
                      onMenu: () {
                        if (compact) {
                          scaffold.currentState?.openDrawer();
                        } else {
                          setState(() => sidebarVisible = !sidebarVisible);
                        }
                      },
                    ),
                    Tooltip(
                      message: context.t(storageLabel),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          context.t(storageLabel),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              key: ValueKey(app.page),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: buildPage(
                                  app.page,
                                  availableHeight: constraints.maxHeight - 24,
                                ),
                              ),
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
