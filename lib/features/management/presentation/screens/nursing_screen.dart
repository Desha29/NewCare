import 'package:flutter/material.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../widgets/nursing_editor.dart';
class NursingScreen extends StatelessWidget{const NursingScreen({super.key});@override Widget build(BuildContext context){final summary=summaryFor(context);return NcPageColumn(children:[const PeriodFilter(),StaffCasesChart(summary:summary),const NursingListPanel(),const NursingEditor()]);}}

