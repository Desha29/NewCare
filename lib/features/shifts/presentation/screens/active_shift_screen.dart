import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_staff_tile.dart';
import '../../../cases/presentation/widgets/case_list.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
class ActiveShiftScreen extends StatelessWidget{
  const ActiveShiftScreen({super.key,this.localQueue=false});final bool localQueue;
  @override Widget build(BuildContext context){
    final data=context.watch<WorkspaceCubit>().state;final shift=data.activeShift;final app=context.read<AppCubit>();
    if(shift==null)return NcEmpty(message:context.t('noShift'),action:NcButton(label:context.t('startShift'),onPressed:()=>app.navigate(AppPage.startShift)));
    final records=data.cases.where((c)=>c.shiftId==shift.id).toList().reversed.toList();
    return NcPageColumn(children:[if(localQueue)NcNotice(title:context.t('offlineNote'),detail:context.t('pendingSync'),tone:NoticeTone.warning),NcCard(title:context.t('currentNursing'),children:[for(final member in data.staff.where((n)=>shift.memberIds.contains(n.id)))NcStaffTile(member:member,selected:context.watch<AppCubit>().state.staffId==member.id,subtitle:context.t('active'),onTap:()=>app.selectStaff(member.id)),Align(alignment:AlignmentDirectional.centerStart,child:TextButton.icon(onPressed:()=>app.navigate(AppPage.joinShift),icon:const Icon(Icons.person_add_alt,size:17),label:Text(context.t('joinShift'))))]),NcActionRow(children:[NcButton(label:context.t('addInside'),icon:Icons.add,onPressed:()=>app.navigate(AppPage.insideCase)),NcButton(label:context.t('addOutside'),icon:Icons.add,secondary:true,onPressed:()=>app.navigate(AppPage.outsideCase))]),NcCard(title:'${context.t('lastCases')} · ${records.length}',children:[CaseList(records:records.take(3).toList(),workspace:data),TextButton(onPressed:()=>app.navigate(AppPage.shiftCases),child:Text(context.t('viewHistory')))]),Align(alignment:AlignmentDirectional.centerStart,child:TextButton.icon(onPressed:()=>app.navigate(AppPage.endShift),icon:const Icon(Icons.logout,size:18),label:Text(context.t('endShift'))))]);
  }
}

