import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_metric_grid.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../drawer/presentation/widgets/movement_form.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
class PayrollScreen extends StatelessWidget{const PayrollScreen({super.key});@override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;final summary=summaryFor(context);return NcPageColumn(children:[const PeriodFilter(),NcMetricGrid(items:[MetricValue(context.t('advanceTotal'),context.money(summary.advanceMinor)),MetricValue(context.t('payroll'),context.t('payrollPending'))]),NcBarChart(title:context.t('outstandingAdvances'),values:data.staff.take(5).map((n)=>ChartValue(n.name.split(' ').first,summary.movements.where((m)=>m.kind==CashKind.advance&&m.staffId==n.id).fold<int>(0,(s,m)=>s+m.amountMinor)/100)).toList()),NcNotice(title:context.t('payrollPending'),detail:context.t('payrollExplanation')),const MovementForm(advance:true),NcNotice(title:context.t('advanceNote'))]);}}

