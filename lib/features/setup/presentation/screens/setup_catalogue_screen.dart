import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../management/presentation/widgets/catalogue_editor.dart';
import '../../../management/presentation/cubit/management_cubit.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
class SetupCatalogueScreen extends StatefulWidget{const SetupCatalogueScreen({super.key});@override State<SetupCatalogueScreen> createState()=>_SetupCatalogueScreenState();}
class _SetupCatalogueScreenState extends State<SetupCatalogueScreen>{
  final amount=TextEditingController();final form=GlobalKey<FormState>();
  @override void dispose(){amount.dispose();super.dispose();}
  @override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;return NcPageColumn(maxWidth:900,children:[const CatalogueEditor(),const CatalogueEditor(supply:true),const OperationError<ManagementCubit>(),if(data.shifts.isEmpty)Form(key:form,child:NcCard(title:context.t('openingCash'),children:[NcField(label:context.t('openingCash'),controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),validator:(v){try{Money.parse(v??'');return null;}catch(_){return context.t('invalidAmount');}})]))else NcNotice(title:context.t('configured')),NcButton(label:context.t('saveAndContinue'),onPressed:()async{if(data.shifts.isEmpty&&!form.currentState!.validate())return;final success=await context.read<ManagementCubit>().settings(opening:data.shifts.isEmpty?Money.parse(amount.text):null,complete:true);if(success&&context.mounted)context.read<AppCubit>().navigate(AppPage.ready);})]);}
}

