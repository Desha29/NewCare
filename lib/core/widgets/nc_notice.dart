import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum NoticeTone { info, warning, danger, success }

class NcNotice extends StatelessWidget {
  const NcNotice({
    super.key,
    required this.title,
    this.detail,
    this.tone = NoticeTone.info,
  });
  final String title;
  final String? detail;
  final NoticeTone tone;
  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      NoticeTone.warning => AppColors.warningBg,
      NoticeTone.danger => AppColors.dangerBg,
      _ => AppColors.tealLight,
    };
    final color = switch (tone) {
      NoticeTone.warning => AppColors.warning,
      NoticeTone.danger => AppColors.danger,
      NoticeTone.success => AppColors.success,
      _ => AppColors.navy,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tone == NoticeTone.success
                ? Icons.check_circle_outline
                : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(detail!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
