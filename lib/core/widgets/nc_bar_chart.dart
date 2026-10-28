import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'nc_card.dart';

class ChartValue {
  const ChartValue(this.label, this.value);
  final String label;
  final double value;
}

class NcBarChart extends StatelessWidget {
  const NcBarChart({
    super.key,
    required this.title,
    required this.values,
    this.subtitle,
  });
  final String title;
  final List<ChartValue> values;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(1, (v, e) => e.value > v ? e.value : v);
    return NcCard(
      title: title,
      children: [
        if (subtitle != null)
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: values
                .map(
                  (e) => Expanded(
                    child: Semantics(
                      label: '${e.label}: ${e.value}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              e.value % 1 == 0
                                  ? e.value.toInt().toString()
                                  : e.value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Container(
                                width: 48,
                                height: 130 * e.value / max,
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 32,
                              child: Text(
                                e.label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
