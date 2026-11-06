import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/center_clock.dart';
import '../../core/debug/device_preview_panel.dart';
import '../cubit/app_cubit.dart';
import '../../features/sync/data/repositories/cloud_sync_service.dart';

class WorkspaceHeader extends StatefulWidget {
  const WorkspaceHeader({
    super.key,
    required this.onMenu,
    this.compact = false,
    this.showShiftControls = false,
    this.title,
    this.navigationOpen = false,
    this.syncService,
  });
  final VoidCallback onMenu;
  final bool compact;
  final bool showShiftControls;
  final String? title;
  final bool navigationOpen;
  final CloudSyncService? syncService;
  @override
  State<WorkspaceHeader> createState() => _WorkspaceHeaderState();
}

class _WorkspaceHeaderState extends State<WorkspaceHeader> {
  late final Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = CenterClock.now();
    final locale = Localizations.localeOf(context).languageCode;
    final sync = widget.syncService;
    final Listenable syncListenable =
        widget.syncService ?? _NoopListenable.instance;
    return AnimatedBuilder(
      animation: syncListenable,
      builder: (context, _) {
        final syncColor = sync == null
            ? AppColors.teal
            : switch (sync.state) {
                CloudSyncState.online => AppColors.teal,
                CloudSyncState.syncing => AppColors.warning,
                CloudSyncState.pending => AppColors.warning,
                CloudSyncState.offline => AppColors.danger,
              };
        final syncLabel = sync == null
            ? context.t('localSaved')
            : switch (sync.state) {
                CloudSyncState.online => context.t('syncOnline'),
                CloudSyncState.syncing => context.t('syncing'),
                CloudSyncState.pending => context.t('syncPending'),
                CloudSyncState.offline => context.t('syncOffline'),
              };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final gap = wide ? 16.0 : 8.0;
                const metadataStyle = TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                );
                final narrow = constraints.maxWidth < 480;
                final metadata = Wrap(
                  spacing: gap,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: syncLabel,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: syncColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          ...[
                            const SizedBox(width: 6),
                            Text(
                              syncLabel,
                              style: TextStyle(fontSize: 11, color: syncColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (sync != null && sync.pendingOperations > 0) ...[
                      SizedBox(width: gap),
                      Text(
                        '${context.t('syncPending')}: ${sync.pendingOperations}',
                        style: metadataStyle.copyWith(color: AppColors.warning),
                      ),
                    ],
                    Text(
                      DateFormat(
                        wide ? 'EEE, d MMM y' : 'd/M/y',
                        locale,
                      ).format(now),
                      style: metadataStyle,
                      maxLines: 1,
                    ),
                    Text(
                      DateFormat.jm(locale).format(now),
                      style: metadataStyle,
                      maxLines: 1,
                    ),
                  ],
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 44,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: widget.onMenu,
                          icon: Icon(
                            widget.navigationOpen
                                ? Icons.menu_open
                                : Icons.menu,
                          ),
                          tooltip: context.t(
                            widget.compact
                                ? 'openNavigation'
                                : widget.navigationOpen
                                ? 'hideSidebar'
                                : 'showSidebar',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (kDebugMode && DevicePreview.maybeController != null)
                          IconButton(
                            tooltip: context.t('devicePreview'),
                            onPressed: () => DevicePreviewPanel.open(context),
                            icon: const Icon(Icons.devices_outlined, size: 20),
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 44,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        if (!narrow) ...[const SizedBox(width: 8), metadata],
                        IconButton(
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 44,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              context.read<AppCubit>().toggleLocale(),
                          icon: const Icon(Icons.language, size: 20),
                          tooltip: context.t('language'),
                        ),
                      ],
                    ),
                    if (narrow)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: metadata,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _NoopListenable extends ChangeNotifier {
  _NoopListenable._();
  static final instance = _NoopListenable._();
}
