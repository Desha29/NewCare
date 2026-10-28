import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/management_cubit.dart';

class ManagerProfileEditor extends StatefulWidget {
  const ManagerProfileEditor({super.key, this.onSaved});
  final VoidCallback? onSaved;
  @override
  State<ManagerProfileEditor> createState() => _ManagerProfileEditorState();
}

class _ManagerProfileEditorState extends State<ManagerProfileEditor> {
  final name = TextEditingController(),
      email = TextEditingController(),
      form = GlobalKey<FormState>();
  bool loaded = false, saved = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      final data = context.read<WorkspaceCubit>().state;
      name.text = data.managerName;
      email.text = data.managerEmail;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('managerArea'),
      children: [
        const OperationError<ManagementCubit>(),
        if (saved)
          NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
        NcField(
          label: context.t('managerName'),
          controller: name,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        NcField(
          label: context.t('email'),
          controller: email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              v == null || !v.contains('@') ? context.t('requiredField') : null,
        ),
        NcButton(
          label: context.t('save'),
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            if (await context.read<ManagementCubit>().settings(
                  name: name.text.trim(),
                  email: email.text.trim(),
                ) &&
                context.mounted) {
              setState(() => saved = true);
              widget.onSaved?.call();
            }
          },
        ),
      ],
    ),
  );
}
