import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NcTabItem<T> {
  const NcTabItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class NcTabs<T> extends StatelessWidget {
  const NcTabs({
    super.key,
    required this.selected,
    required this.items,
    required this.onChanged,
    this.maxWidth = 360,
  });

  final T selected;
  final List<NcTabItem<T>> items;
  final ValueChanged<T> onChanged;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final body = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: maxWidth != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final item in items)
              Expanded(
                child: Semantics(
                  selected: selected == item.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: selected == item.value
                            ? AppColors.navy
                            : Colors.transparent,
                        foregroundColor: selected == item.value
                            ? Colors.white
                            : AppColors.navy,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => onChanged(item.value),
                      icon: item.icon != null
                          ? Icon(
                              item.icon,
                              size: 17,
                              color: selected == item.value
                                  ? Colors.white
                                  : AppColors.navy,
                            )
                          : const SizedBox.shrink(),
                      label: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: body,
      );
    }
    return body;
  }
}

