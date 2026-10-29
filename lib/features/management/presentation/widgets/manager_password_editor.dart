import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_button.dart';

class ManagerPasswordEditor extends StatefulWidget {
  const ManagerPasswordEditor({super.key});
  @override
  State<ManagerPasswordEditor> createState() => _ManagerPasswordEditorState();
}

class _ManagerPasswordEditorState extends State<ManagerPasswordEditor> {
  final current = TextEditingController(),
      next = TextEditingController(),
      confirm = TextEditingController();
  final form = GlobalKey<FormState>();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final failure = await context.read<AppCubit>().changePassword(
        current.text,
        next.text,
      );
      if (!mounted) return;
      if (failure == null) {
        current.clear();
        next.clear();
        confirm.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.t('passwordUpdated'))));
      } else {
        setState(() => error = failure);
      }
    } catch (_) {
      if (mounted) setState(() => error = 'settingsSaveFailed');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('changePassword'),
      children: [
        if (error != null)
          Text(
            context.t(error!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        NcField(
          label: context.t('currentPassword'),
          controller: current,
          obscure: true,
          validator: (v) =>
              v == null || v.isEmpty ? context.t('requiredField') : null,
        ),
        NcField(
          label: context.t('newPassword'),
          controller: next,
          obscure: true,
          validator: (v) =>
              (v?.length ?? 0) < 8 ? context.t('passwordTooShort') : null,
        ),
        NcField(
          label: context.t('confirmPassword'),
          controller: confirm,
          obscure: true,
          validator: (v) =>
              v != next.text ? context.t('passwordMismatch') : null,
        ),
        NcButton(label: context.t('save'), onPressed: saving ? null : save),
      ],
    ),
  );
}
