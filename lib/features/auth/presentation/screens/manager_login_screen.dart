import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_logo.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
class ManagerLoginScreen extends StatefulWidget{const ManagerLoginScreen({super.key});@override State<ManagerLoginScreen> createState()=>_ManagerLoginScreenState();}
class _ManagerLoginScreenState extends State<ManagerLoginScreen>{
  final password=TextEditingController();bool error=false;
  @override void dispose(){password.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>NcPageColumn(maxWidth:680,children:[const NcLogo(full:true,size:160),NcNotice(title:context.t('previewGate'),detail:context.t('previewPassword'),tone:NoticeTone.warning),NcCard(title:context.t('login'),children:[if(error)NcNotice(title:context.t('wrongPassword'),tone:NoticeTone.danger),NcField(label:context.t('password'),controller:password,obscure:true),NcButton(label:context.t('signIn'),onPressed:(){if(!context.read<AppCubit>().unlock(password.text))setState(()=>error=true);})]),NcButton(label:context.t('returnNursing'),secondary:true,onPressed:()=>context.read<AppCubit>().navigate(AppPage.activeShift)),TextButton(onPressed:()=>context.read<AppCubit>().navigate(AppPage.setup),child:Text(context.t('showSetup')))]);
}

