import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../management/presentation/cubit/management_cubit.dart';
class SetupScreen extends StatefulWidget{const SetupScreen({super.key});@override State<SetupScreen> createState()=>_SetupScreenState();}
class _SetupScreenState extends State<SetupScreen>{
  final form=GlobalKey<FormState>();final name=TextEditingController(),email=TextEditingController();
  @override void dispose(){name.dispose();email.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Form(key:form,child:NcPageColumn(maxWidth:800,children:[NcNotice(title:context.t('setupSteps'),detail:context.t('previewGate')),const OperationError<ManagementCubit>(),NcCard(title:context.t('setup'),children:[NcField(label:context.t('managerName'),controller:name,validator:(v)=>v==null||v.trim().isEmpty?context.t('requiredField'):null),NcField(label:context.t('email'),controller:email,keyboardType:TextInputType.emailAddress,validator:(v)=>v==null||!v.contains('@')?context.t('requiredField'):null)]),NcButton(label:context.t('createManager'),onPressed:()async{if(!form.currentState!.validate())return;if(await context.read<ManagementCubit>().settings(name:name.text.trim(),email:email.text.trim())&&context.mounted)context.read<AppCubit>().navigate(AppPage.setupNursing);})]));
}

