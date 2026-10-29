import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../theme/app_colors.dart';

class NcStatusBadge extends StatelessWidget {
  const NcStatusBadge(this.value, {super.key});
  final String value;
  static (Color, Color) colors(String value) => switch (value) {
    'drawerMatched' => (const Color(0xFFE2F3E8), const Color(0xFF216B42)),
    'drawerShortage' => (AppColors.dangerBg, AppColors.danger),
    'drawerExcess' => (AppColors.warningBg, AppColors.warning),
    'inside' => (AppColors.tealLight, AppColors.navy),
    'outside' => (const Color(0xFFFFEAD5), const Color(0xFF904309)),
    'cash' => (const Color(0xFFE2F3E8), const Color(0xFF216B42)),
    'wallet' => (const Color(0xFFF0E9FA), const Color(0xFF67429A)),
    _ => (AppColors.background, AppColors.navy),
  };
  @override
  Widget build(BuildContext context) {
    final (background, foreground) = colors(value);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          context.t(value),
          softWrap: true,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
