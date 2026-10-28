import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_staff_tile.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/shift_cubit.dart';
class JoinShiftScreen extends StatefulWidget{const JoinShiftScreen({super.key});@override State<JoinShiftScreen> createState()=>_JoinShiftScreenState();}
class _JoinShiftScreenState extends State<JoinShiftScreen>{
  String? selected;
  @override Widget build(BuildContext context){final data=context.watch<WorkspaceCubit>().state;final shift=data.activeShift;final candidates=data.staff.where((n)=>n.active&&!(shift?.memberIds.contains(n.id)??false)).toList();return NcPageColumn(maxWidth:800,children:[const OperationError<ShiftCubit>(),NcCard(title:context.t('selectStaff'),children:[for(final n in candidates)NcStaffTile(member:n,selected:selected==n.id,onTap:()=>setState(()=>selected=n.id)),if(candidates.isEmpty)NcNotice(title:context.t('noResults'))]),NcButton(label:context.t('confirmJoin'),onPressed:selected==null?null:()async{final success=await context.read<ShiftCubit>().join(selected!);if(context.mounted&&success)context.read<AppCubit>().navigate(AppPage.activeShift);})]);}
}

