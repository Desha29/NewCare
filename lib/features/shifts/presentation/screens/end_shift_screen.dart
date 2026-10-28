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
import '../../../../core/widgets/nc_staff_tile.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/shift_cubit.dart';
class EndShiftScreen extends StatefulWidget{const EndShiftScreen({super.key});@override State<EndShiftScreen> createState()=>_EndShiftScreenState();}
class _EndShiftScreenState extends State<EndShiftScreen>{
  final note=TextEditingController();
  @override void dispose(){note.dispose();super.dispose();}
  @override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;final shift=data.activeShift;return NcPageColumn(maxWidth:860,children:[const OperationError<ShiftCubit>(),NcNotice(title:context.t('finishNote')),NcCard(title:context.t('staffBreakdown'),children:[for(final member in data.staff.where((n)=>shift?.memberIds.contains(n.id)??false))NcStaffTile(member:member,subtitle:'${data.cases.where((c)=>c.shiftId==shift?.id&&c.staffId==member.id).length} ${context.t('cases')}'),NcField(label:context.t('handoverNotes'),controller:note,lines:3)]),NcButton(label:context.t('finishShift'),onPressed:shift==null?null:()async{if(await context.read<ShiftCubit>().end(note.text)&&context.mounted)context.read<AppCubit>().navigate(AppPage.handover);})]);}
}

