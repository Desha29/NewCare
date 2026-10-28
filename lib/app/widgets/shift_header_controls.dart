import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/app_cubit.dart';
import '../navigation/app_page.dart';

class ShiftHeaderControls extends StatelessWidget {
  const ShiftHeaderControls({super.key});
  @override
  Widget build(BuildContext context) {
    final open = context.watch<WorkspaceCubit>().state.activeShift != null;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: open ? AppColors.teal : AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  context.t(open ? 'shiftOpen' : 'shiftClosed'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: open ? AppColors.teal : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 108,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.success.withValues(alpha: .12),
              disabledForegroundColor: AppColors.success.withValues(alpha: .65),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: open
                ? null
                : () => context.read<AppCubit>().navigate(AppPage.startShift),
            child: Text(
              context.t('startShift'),
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 100,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.danger.withValues(alpha: .12),
              disabledForegroundColor: AppColors.danger.withValues(alpha: .65),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: open
                ? () => context.read<AppCubit>().navigate(AppPage.endShift)
                : null,
            child: Text(
              context.t('endShift'),
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
