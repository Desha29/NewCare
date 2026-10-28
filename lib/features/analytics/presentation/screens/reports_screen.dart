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
          title: context.t('totalRevenue'),
          values: data.procedures
              .take(5)
              .map(
                (p) => ChartValue(
                  p.name(Localizations.localeOf(context).languageCode),
                  summary.cases
                          .where((c) => c.procedureId == p.id)
                          .fold<int>(0, (v, c) => v + c.amountMinor) /
                      100,
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
              final rows = [
                [
                  context.t('caseTitle'),
                  context.t('caseOwner'),
                  context.t('amount'),
                  context.t('paymentMethod'),
                  context.t('time'),
                ],
                ...summary.cases.map(
                  (c) => [
                    c.title,
                    data.staff
                            .where((n) => n.id == c.staffId)
                            .firstOrNull
                            ?.name ??
                        c.staffId,
                    (c.amountMinor / 100).toStringAsFixed(2),
                    context.t(c.payment.name),
                    c.createdAt.toIso8601String(),
                  ],
                ),
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
