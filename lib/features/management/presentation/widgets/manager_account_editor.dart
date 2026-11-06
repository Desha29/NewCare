import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';

class ManagerAccountEditor extends StatefulWidget {
  const ManagerAccountEditor({super.key, this.onSaved});
  final VoidCallback? onSaved;
  @override
  State<ManagerAccountEditor> createState() => _ManagerAccountEditorState();
}

class _ManagerAccountEditorState extends State<ManagerAccountEditor> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      username = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool busy = false, submitted = false;
  String? error;
  @override
  void dispose() {
    for (final controller in [name, username, email, password]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('addManager'),
      children: [
        Text(context.t('managerAccountsHelp')),
        if (error != null)
          NcNotice(title: context.t(error!), tone: NoticeTone.danger),
        if (submitted)
          NcNotice(
            title: context.t('managerInvitationSent'),
            tone: NoticeTone.success,
          ),
        NcField(
          label: context.t('memberName'),
          controller: name,
          enabled: !busy && !submitted,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        NcField(
          label: context.t('username'),
          controller: username,
          enabled: !busy && !submitted,
          hint: context.t('usernameHint'),
          validator: (v) =>
              RegExp(r'^[a-z0-9_]{3,32}$')
                  .hasMatch(v?.trim().toLowerCase() ?? '')
              ? null
              : context.t('usernameHint'),
        ),
        NcField(
          label: context.t('email'),
          controller: email,
          enabled: !busy && !submitted,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              v != null && RegExp(r'^[^ @]+@[^ @]+\.[^ @]+$').hasMatch(v.trim())
              ? null
              : context.t('invalidEmail'),
        ),
        NcField(
          label: context.t('newPassword'),
          controller: password,
          obscure: true,
          enabled: !busy && !submitted,
          validator: (v) =>
              (v?.length ?? 0) >= 8 ? null : context.t('securePasswordHint'),
        ),
        NcButton(
          label: context.t(submitted ? 'close' : 'addManager'),
          busy: busy,
          onPressed: () async {
            if (submitted) {
              widget.onSaved?.call();
              return;
            }
            if (!form.currentState!.validate()) return;
            setState(() {
              busy = true;
              error = null;
            });
            final result = await context.read<AppCubit>().createManager(
              username: username.text.trim().toLowerCase(),
              name: name.text.trim(),
              email: email.text.trim(),
              password: password.text,
            );
            if (!mounted) return;
            setState(() {
              busy = false;
              error = result;
              submitted = result == null;
            });
            if (result == null) password.clear();
          },
        ),
      ],
    ),
  );
}
