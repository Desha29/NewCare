import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class ShiftNursingGrid extends StatelessWidget {
  const ShiftNursingGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state,
        app = context.watch<AppCubit>().state;
    final shift = data.activeShift;
    final members = data.staff.where(
      (n) => n.active && (shift?.memberIds.contains(n.id) ?? false),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final columns = ((c.maxWidth + 12) / 160).floor().clamp(1, 8);
        final width = (c.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final n in members)
              SizedBox(
                width: width,
                child: Semantics(
                  selected: app.staffId == n.id,
                  child: Material(
                    color: app.staffId == n.id
                        ? AppColors.tealLight
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => context.read<AppCubit>().selectStaff(n.id),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: app.staffId == n.id
                                ? AppColors.teal
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.background,
                              child: Icon(
                                app.staffId == n.id
                                    ? Icons.check
                                    : Icons.person_outline,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              context.t(n.isManager ? 'manager' : 'nursing'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${context.t('cases')}: ${data.cases.where((r) => r.shiftId == shift?.id && r.staffId == n.id).length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
