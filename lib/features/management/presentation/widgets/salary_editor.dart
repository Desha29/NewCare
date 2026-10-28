import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/managed_record_kind.dart';
import '../cubit/management_cubit.dart';

class SalaryEditor extends StatefulWidget {
  const SalaryEditor({super.key, required this.onSaved});
  final VoidCallback onSaved;
  @override
  State<SalaryEditor> createState() => _SalaryEditorState();
}

class _SalaryEditorState extends State<SalaryEditor> {
  final form = GlobalKey<FormState>();
  final salary = TextEditingController();
  String? staff;
  @override
  void dispose() {
    salary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = context
        .watch<WorkspaceCubit>()
        .state
        .staff
        .where((n) => n.active)
        .toList();
    return Form(
      key: form,
      child: NcCard(
        title: context.t('setSalary'),
        children: [
          const OperationError<ManagementCubit>(),
          NcSelect<String>(
            label: context.t('nursing'),
            value: staff,
            items: members
                .map(
                  (n) => DropdownMenuItem(
                    value: n.id,
                    child: Text(
                      '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                    ),
                  ),
                )
                .toList(),
            validator: (v) => v == null ? context.t('requiredField') : null,
            onChanged: (v) => setState(() {
              staff = v;
              salary.text =
                  (members.firstWhere((n) => n.id == v).salaryMinor / 100)
                      .toStringAsFixed(2);
            }),
          ),
          NcField(
            label: context.t('monthlySalary'),
            controller: salary,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              try {
                Money.parse(v ?? '');
                return null;
              } catch (_) {
                return context.t('invalidAmount');
              }
            },
          ),
          NcButton(
            label: context.t('save'),
            busy: context.watch<ManagementCubit>().state.busy,
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              if (await context.read<ManagementCubit>().updateRecord(
                    ManagedRecordKind.nursing,
                    staff!,
                    {'salary': Money.parse(salary.text)},
                    context.t('salaryUpdated'),
                  ) &&
                  context.mounted) {
                widget.onSaved();
              }
            },
          ),
        ],
      ),
    );
  }
}
