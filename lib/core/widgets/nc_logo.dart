import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NcLogo extends StatelessWidget {
  const NcLogo({
    super.key,
    this.dark = false,
    this.full = false,
    this.size = 48,
    this.wordmark = true,
  });
  final bool dark, full, wordmark;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (full) {
      return Image.asset(
        'assets/branding/newcare-logo.png',
        height: size,
        fit: BoxFit.contain,
        semanticLabel: 'NewCare',
      );
    }
    final icon = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/branding/newcare-icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticLabel: 'NewCare',
      ),
    );
    if (!wordmark) return icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'NewCare',
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : AppColors.navyDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
