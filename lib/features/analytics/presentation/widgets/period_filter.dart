import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/utils/formatters.dart';

import 'package:intl/intl.dart';

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
    final locale = Localizations.localeOf(context).languageCode;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Tooltip(
          message:
              '${context.t('period')}: ${context.calendarDate(selected.start)} — ${context.calendarDate(selected.end)}',
          child: OutlinedButton.icon(
            onPressed: () => pick(context),
            icon: const Icon(Icons.calendar_today_outlined, size: 15),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            label: Text(
              '${DateFormat.yMd(locale).format(selected.start)} — ${DateFormat.yMd(locale).format(selected.end)}',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
        for (final key in ['today', 'week', 'month'])
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
            child: Text(context.t(key), style: const TextStyle(fontSize: 11)),
          ),
        TextButton(
          onPressed: () => pick(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.t('custom'),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
