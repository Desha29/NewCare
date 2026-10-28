import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NcEmpty extends StatelessWidget {
  const NcEmpty({super.key, required this.message, this.action});
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 32, color: AppColors.muted),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}
