import '../../../../core/localization/localization_extensions.dart';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AnimatedBrandMark extends StatelessWidget {
  const AnimatedBrandMark({
    super.key,
    required this.animation,
    this.diameter = 180,
  });
  final Animation<double> animation;
  final double diameter;
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: .88, end: 1).animate(animation),
      child: Container(
        width: diameter,
        height: diameter,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.tealLight,
          border: Border.all(color: AppColors.teal.withValues(alpha: .22)),
        ),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: .06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/branding/newcare-icon.png',
              fit: BoxFit.contain,
              semanticLabel: context.t('brandName'),
            ),
          ),
        ),
      ),
    ),
  );
}
