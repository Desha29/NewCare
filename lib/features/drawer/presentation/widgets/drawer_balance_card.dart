import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class DrawerBalanceCard extends StatelessWidget {
  const DrawerBalanceCard({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final holder = data.staff
        .where((n) => n.id == data.drawerHolder)
        .firstOrNull;
    final lastCount = data.handovers.lastOrNull;
    return NcCard(
      title: context.t('drawerStatus'),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Icon(
                  Icons.point_of_sale_outlined,
                  color: AppColors.teal,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.t('drawerBalance'),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  key: ValueKey(data.drawerBalance),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.money(data.drawerBalance),
                      key: const ValueKey('live-drawer-balance'),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: data.drawerBalance < 0
                            ? AppColors.danger
                            : AppColors.navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          context.t('cashDrawerHint'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 1),
        Text(
          context.t('drawerHolder'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          holder == null
              ? context.t('unassignedDrawerHolder')
              : '${holder.name}${holder.isManager ? ' · ${context.t('manager')}' : ''}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (lastCount != null) ...[
          Text(
            context.t('lastDrawerCheck'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NcStatusBadge(lastCount.statusKey),
          ),
        ],
      ],
    );
  }
}
