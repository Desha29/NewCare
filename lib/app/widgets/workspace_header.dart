import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/center_clock.dart';
import '../../core/widgets/nc_logo.dart';
import '../cubit/app_cubit.dart';
import 'shift_header_controls.dart';

class WorkspaceHeader extends StatefulWidget {
  const WorkspaceHeader({
    super.key,
    required this.onMenu,
    this.compact = false,
    this.showShiftControls = true,
  });
  final VoidCallback onMenu;
  final bool compact;
  final bool showShiftControls;
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
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.compact)
                  IconButton(
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 44,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: widget.onMenu,
                    icon: const Icon(Icons.menu),
                    tooltip: context.t('settings'),
                  ),
                NcLogo(size: wide ? 44 : 32, wordmark: wide),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: context.t('localSaved'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (wide) ...[
                            const SizedBox(width: 6),
                            Text(
                              context.t('localSaved'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: gap),
                    Text(
                      DateFormat(
                        wide ? 'EEE, d MMM y' : 'd/M/y',
                        locale,
                      ).format(now),
                      style: metadataStyle,
                      maxLines: 1,
                    ),
                    SizedBox(width: gap),
                    Text(
                      DateFormat.jm(locale).format(now),
                      style: metadataStyle,
                      maxLines: 1,
                    ),
                  ],
                ),
                IconButton(
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 44,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => context.read<AppCubit>().toggleLocale(),
                  icon: const Icon(Icons.language, size: 20),
                  tooltip: context.t('language'),
                ),
              ],
            );
          },
        ),
        if (widget.showShiftControls) ...[
          const SizedBox(height: 8),
          const ShiftHeaderControls(),
        ],
      ],
    );
  }
}
