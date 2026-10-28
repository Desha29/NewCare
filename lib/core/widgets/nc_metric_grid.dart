import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MetricValue {
  const MetricValue(this.label, this.value, {this.detail});
  final String label, value;
  final String? detail;
}

class NcMetricGrid extends StatelessWidget {
  const NcMetricGrid({super.key, required this.items});
  final List<MetricValue> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final columns = c.maxWidth < 600
          ? 2
          : c.maxWidth < 900
          ? 2
          : 4;
      final width = (c.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items
            .map(
              (m) => SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              m.value,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        if (m.detail != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            m.detail!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}
