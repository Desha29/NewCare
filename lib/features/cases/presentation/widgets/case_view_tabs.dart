import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class CaseViewTabs extends StatelessWidget {
  const CaseViewTabs({super.key, required this.cards, required this.onChanged});
  final bool cards;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 300),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final value in [true, false])
              Expanded(
                child: Semantics(
                  selected: cards == value,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: cards == value
                          ? AppColors.navy
                          : Colors.transparent,
                      foregroundColor: cards == value
                          ? Colors.white
                          : AppColors.navy,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => onChanged(value),
                    icon: Icon(
                      value
                          ? Icons.grid_view_outlined
                          : Icons.table_rows_outlined,
                      size: 17,
                    ),
                    label: Text(
                      context.t(value ? 'cardView' : 'tableView'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
