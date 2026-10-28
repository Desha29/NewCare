import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_bar_chart.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_staff_tile.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/report_summary.dart';
import 'period_filter.dart';
ReportSummary summaryFor(BuildContext context){final range=PeriodFilter.range(context);return ReportSummary.forRange(context.watch<WorkspaceCubit>().state,range.start,range.end);}
class DailyRevenueChart extends StatelessWidget{
  const DailyRevenueChart({super.key,required this.summary});final ReportSummary summary;
  @override Widget build(BuildContext context){final locale=Localizations.localeOf(context).languageCode;final end=summary.end.subtract(const Duration(days:1));return NcBarChart(title:context.t('dailyRevenue'),subtitle:context.t('sampleOnly'),values:List.generate(5,(i){final day=DateTime(end.year,end.month,end.day-(4-i));final sum=summary.cases.where((c){final d=CenterClock.local(c.createdAt);return d.year==day.year&&d.month==day.month&&d.day==day.day;}).fold<int>(0,(v,c)=>v+c.amountMinor);return ChartValue(DateFormat('EEE',locale).format(day),sum/100);}));}
}
class StaffCasesChart extends StatelessWidget{
  const StaffCasesChart({super.key,required this.summary});final ReportSummary summary;
  @override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;return NcBarChart(title:context.t('staffBreakdown'),values:data.staff.take(5).map((n)=>ChartValue(n.name.split(' ').first,summary.cases.where((c)=>c.staffId==n.id).length.toDouble())).toList());}
}
class NursingListPanel extends StatelessWidget{
  const NursingListPanel({super.key});@override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;return NcCard(title:context.t('nursing'),children:[for(final member in data.staff)NcStaffTile(member:member,subtitle:context.t(member.active?'active':'closed'))]);}
}

