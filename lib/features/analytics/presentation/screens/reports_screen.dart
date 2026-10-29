import '../../../transactions/presentation/widgets/transaction_labels.dart';
import '../../../transactions/data/models/transaction_entry.dart';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/services/csv_exporter.dart';
import '../widgets/analytics_sections.dart';
import '../widgets/period_filter.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final summary = summaryFor(context);
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        NcMetricGrid(
          items: [
            MetricValue(
              context.t('cashRevenue'),
              context.money(summary.cashMinor),
            ),
            MetricValue(
              context.t('walletRevenue'),
              context.money(summary.walletMinor),
            ),
          ],
        ),
        NcBarChart(
          title: context.t('caseCount'),
          values: data.procedures
              .take(5)
              .map(
                (p) => ChartValue(
                  p.name(Localizations.localeOf(context).languageCode),
                  summary.cases
                      .where((c) => c.effectiveProcedureIds.contains(p.id))
                      .length
                      .toDouble(),
                ),
              )
              .toList(),
        ),
        NcNotice(title: context.t('cashFormula')),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NcButton(
            label: context.t('exportReport'),
            icon: Icons.download_outlined,
            secondary: true,
            onPressed: () async {
              final range = PeriodFilter.range(context);
              final entries = TransactionEntry.forRange(
                data,
                range.start,
                range.end,
              );
              final rows = [
                [
                  context.t('dateAndTime'),
                  context.t('movementKind'),
                  context.t('reason'),
                  context.t('nursing'),
                  context.t('paymentMethod'),
                  context.t('amount'),
                ],
                for (final entry in entries)
                  [
                    '${context.date(entry.at)} · ${context.time(entry.at)}',
                    transactionCategory(context, entry),
                    transactionDescription(context, entry),
                    data.staff
                            .where((n) => n.id == entry.staffId)
                            .firstOrNull
                            ?.name ??
                        '',
                    context.t(entry.payment.name),
                    (entry.signedMinor / 100).toStringAsFixed(2),
                  ],
              ];
              try {
                await FileSaver.instance.saveFile(
                  name: 'newcare-report',
                  bytes: CsvExporter.encode(rows),
                  fileExtension: 'csv',
                  mimeType: MimeType.csv,
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t('saveFailed'))),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
