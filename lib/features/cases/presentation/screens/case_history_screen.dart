import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/case_list.dart';
class CaseHistoryScreen extends StatefulWidget{const CaseHistoryScreen({super.key,this.manager=false});final bool manager;@override State<CaseHistoryScreen> createState()=>_CaseHistoryScreenState();}
class _CaseHistoryScreenState extends State<CaseHistoryScreen>{
  final search=TextEditingController();
  @override void dispose(){search.dispose();super.dispose();}
  @override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;final records=data.cases.where((c)=>(widget.manager||c.shiftId==data.activeShift?.id)&&c.title.toLowerCase().contains(search.text.toLowerCase())).toList().reversed.toList();return NcPageColumn(children:[NcField(label:context.t('search'),controller:search,onChanged:(_)=>setState((){})),NcCard(title:'${context.t('cases')} · ${records.length}',children:[CaseList(records:records,workspace:data)])]);}
}

