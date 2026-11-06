import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../launch/presentation/widgets/animated_brand_mark.dart';

class AuthBrandHeading extends StatelessWidget {
  const AuthBrandHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const AnimatedBrandMark(
        animation: AlwaysStoppedAnimation(1),
        diameter: 80,
      ),
      const SizedBox(height: 20),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(color: AppColors.navy),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.muted),
      ),
    ],
  );
}
