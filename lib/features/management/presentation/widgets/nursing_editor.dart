import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../cubit/management_cubit.dart';

class NursingEditor extends StatefulWidget {
  const NursingEditor({super.key, this.onSaved});
  final VoidCallback? onSaved;
  @override
  State<NursingEditor> createState() => _NursingEditorState();
}

class _NursingEditorState extends State<NursingEditor> {
  final name = TextEditingController(), form = GlobalKey<FormState>();
  bool manager = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('addNursing'),
      children: [
        const OperationError<ManagementCubit>(),
        NcField(
          label: context.t('memberName'),
          controller: name,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.t('isManager')),
          value: manager,
          onChanged: (v) => setState(() => manager = v),
        ),
        NcButton(
          label: context.t('add'),
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            if (await context.read<ManagementCubit>().addStaff(
                  NursingMember(
                    id: const Uuid().v4(),
                    name: name.text.trim(),
                    isManager: manager,
                  ),
                ) &&
                context.mounted) {
              name.clear();
              widget.onSaved?.call();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(context.t('added'))));
            }
          },
        ),
      ],
    ),
  );
}
