import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/center_clock.dart';
import '../../core/widgets/nc_logo.dart';
import '../cubit/app_cubit.dart';

class WorkspaceHeader extends StatefulWidget {
  const WorkspaceHeader({
    super.key,
    required this.onMenu,
    this.compact = false,
  });
  final VoidCallback onMenu;
  final bool compact;
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.compact)
          IconButton(
            onPressed: widget.onMenu,
            icon: const Icon(Icons.menu),
            tooltip: context.t('settings'),
          ),
        const Flexible(flex: 3, child: NcLogo(size: 44)),
        const Spacer(),
        Flexible(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '● ${context.t('localSaved')}',
                style: const TextStyle(fontSize: 10, color: AppColors.teal),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('EEE, d MMM y', locale).format(now),
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
                textAlign: TextAlign.end,
              ),
              Text(
                DateFormat.jm(locale).format(now),
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.read<AppCubit>().toggleLocale(),
          icon: const Icon(Icons.language, size: 20),
          tooltip: context.t('language'),
        ),
      ],
    );
  }
}
