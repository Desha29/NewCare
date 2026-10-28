import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_colors.dart';

class PeriodFilter extends StatelessWidget {
  const PeriodFilter({super.key});
  static DateTimeRange range(BuildContext context) {
    final now = CenterClock.now();
    return context.read<AppCubit>().state.range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day),
        );
  }

  static Future<void> pick(BuildContext context) async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: range(context),
    );
    if (result != null && context.mounted) {
      context.read<AppCubit>().setRange(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppCubit>();
    final selected = range(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t('period'), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Material(
          color: AppColors.background,
          child: InkWell(
            onTap: () => pick(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${context.calendarDate(selected.start)} — ${context.calendarDate(selected.end)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.expand_more, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: [
            for (final key in ['today', 'week', 'month'])
              TextButton(
                onPressed: () {
                  final now = CenterClock.now();
                  final start = switch (key) {
                    'today' => DateTime(now.year, now.month, now.day),
                    'week' => DateTime(now.year, now.month, now.day - 6),
                    _ => DateTime(now.year, now.month, 1),
                  };
                  context.read<AppCubit>().setRange(
                    DateTimeRange(
                      start: start,
                      end: DateTime(now.year, now.month, now.day),
                    ),
                  );
                },
                child: Text(context.t(key)),
              ),
            TextButton(
              onPressed: () => pick(context),
              child: Text(context.t('custom')),
            ),
          ],
        ),
      ],
    );
  }
}
