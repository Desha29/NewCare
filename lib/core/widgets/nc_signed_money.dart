import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class NcSignedMoney extends StatelessWidget {
  const NcSignedMoney(this.minor, {super.key, this.fontSize = 14});
  final int minor;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Text(
    '${minor < 0 ? '−' : '+'} ${context.money(minor.abs())}',
    style: TextStyle(
      color: minor < 0 ? AppColors.danger : AppColors.success,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: fontSize,
    ),
  );
}
