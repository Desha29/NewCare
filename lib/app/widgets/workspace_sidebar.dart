import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/localization_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nc_logo.dart';
import '../cubit/app_cubit.dart';
import '../navigation/app_page.dart';
const nurseNavigation=[AppPage.activeShift,AppPage.shiftCases,AppPage.cashMovement,AppPage.handover];
const managerNavigation=[AppPage.overview,AppPage.shifts,AppPage.caseLog,AppPage.payroll,AppPage.nursing,AppPage.catalogue,AppPage.reports,AppPage.audit,AppPage.permissions];
IconData pageIcon(AppPage p)=>switch(p){AppPage.activeShift=>Icons.schedule,AppPage.shiftCases||AppPage.caseLog=>Icons.folder_open_outlined,AppPage.cashMovement||AppPage.shifts=>Icons.point_of_sale_outlined,AppPage.handover=>Icons.swap_horiz,AppPage.overview=>Icons.bar_chart,AppPage.payroll=>Icons.account_balance_wallet_outlined,AppPage.nursing=>Icons.groups_outlined,AppPage.catalogue=>Icons.medical_services_outlined,AppPage.reports=>Icons.assessment_outlined,AppPage.audit=>Icons.history, _=>Icons.settings_outlined};
class WorkspaceSidebar extends StatelessWidget{
  const WorkspaceSidebar({super.key,this.onSelected});
  final VoidCallback? onSelected;
  @override Widget build(BuildContext context){
    final state=context.watch<AppCubit>().state;
    final manager=state.page.isManager&&state.managerUnlocked;
    final items=manager?managerNavigation:nurseNavigation;
    return ColoredBox(color:AppColors.navyDark,child:SafeArea(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const NcLogo(dark:true,size:64),const SizedBox(height:16),Text(context.t(manager?'managerArea':'nurseArea'),style:const TextStyle(fontSize:11,color:Colors.white70)),const SizedBox(height:20),Expanded(child:ListView(children:[for(final page in items)Padding(padding:const EdgeInsets.only(bottom:6),child:Material(color:state.page==page?Colors.white.withValues(alpha:.13):Colors.transparent,borderRadius:BorderRadius.circular(8),child:InkWell(onTap:(){context.read<AppCubit>().navigate(page);onSelected?.call();},borderRadius:BorderRadius.circular(8),child:Padding(padding:const EdgeInsets.symmetric(vertical:13,horizontal:10),child:Row(children:[Icon(pageIcon(page),size:18,color:state.page==page?const Color(0xFF80D0DB):Colors.white70),const SizedBox(width:10),Expanded(child:Text(context.t(page.labelKey),style:TextStyle(fontSize:11,fontWeight:state.page==page?FontWeight.w700:FontWeight.w400,color:Colors.white)))])))))])),const Divider(color:Colors.white24),TextButton.icon(onPressed:(){if(manager){context.read<AppCubit>().lock();}else{context.read<AppCubit>().navigate(AppPage.overview);}onSelected?.call();},icon:const Icon(Icons.lock_outline,size:17,color:Colors.white70),label:Text(context.t(manager?'lockManager':'login'),style:const TextStyle(color:Colors.white,fontSize:11)))]))));
  }
}

