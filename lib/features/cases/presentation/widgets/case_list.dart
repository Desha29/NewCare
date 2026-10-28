import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/case_record.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
class CaseList extends StatelessWidget{
  const CaseList({super.key,required this.records,required this.workspace});final List<CaseRecord> records;final WorkspaceSnapshot workspace;
  @override Widget build(BuildContext context)=>records.isEmpty?NcEmpty(message:context.t('noCases')):Column(children:[for(final record in records)Padding(padding:const EdgeInsets.only(bottom:10),child:Material(color:Colors.white,child:InkWell(onTap:()=>context.read<AppCubit>().selectCase(record.id),borderRadius:BorderRadius.circular(10),child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(border:Border.all(color:AppColors.border),borderRadius:BorderRadius.circular(10)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Wrap(alignment:WrapAlignment.spaceBetween,spacing:8,children:[Text(record.title,style:const TextStyle(fontWeight:FontWeight.w600)),Text(context.money(record.amountMinor),style:const TextStyle(fontWeight:FontWeight.w600))]),const SizedBox(height:6),Text(_details(context,record),style:Theme.of(context).textTheme.bodySmall)])))))]);
  String _details(BuildContext context,CaseRecord r){final matches=workspace.staff.where((n)=>n.id==r.staffId);final n=matches.firstOrNull;return [n?.name??r.staffId,if(n?.isManager??false)context.t('manager'),context.t(r.location.name),context.t(r.payment.name),context.time(r.createdAt)].join(' · ');}
}

