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
import '../../../../app/cubit/app_cubit.dart';

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
  String? accountError;
  bool busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      final data = context.read<WorkspaceCubit>().state;
      final identity = context.read<AppCubit>().managerIdentity;
      name.text = identity?.name ?? data.managerName;
      email.text = identity?.email ?? data.managerEmail;
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
        if (accountError != null)
          NcNotice(title: context.t(accountError!), tone: NoticeTone.danger),
        if (context.watch<AppCubit>().cloudAuthentication)
          Text(context.t('emailChangeVerificationHelp')),
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
          busy: busy,
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            final app = context.read<AppCubit>();
            if (app.cloudAuthentication) {
              setState(() => busy = true);
              final error = await app.saveManagerProfile(name.text, email.text);
              if (!mounted) return;
              setState(() {
                busy = false;
                accountError = error;
                saved = error == null;
              });
              if (error == null) widget.onSaved?.call();
              return;
            }
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
