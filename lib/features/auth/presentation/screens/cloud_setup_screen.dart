import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_auth_layout.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../data/models/manager_identity.dart';
import '../../data/repositories/cloud_runtime.dart';

class CloudSetupScreen extends StatefulWidget {
  const CloudSetupScreen({
    super.key,
    required this.runtime,
    required this.onReady,
  });
  final CloudRuntime runtime;
  final Future<void> Function(ManagerIdentity) onReady;
  @override
  State<CloudSetupScreen> createState() => _CloudSetupScreenState();
}

class _CloudSetupScreenState extends State<CloudSetupScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      username = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool busy = false;
  String? message;
  bool failure = false;
  @override
  void dispose() {
    for (final controller in [name, username, email, password]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submit(bool activate) async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (!activate) {
        await widget.runtime.requestFirstManager(username.text, password.text);
      }
      final identity = await widget.runtime.activateFirstManager(
        username: username.text,
        name: name.text,
        email: email.text,
        password: password.text,
      );
      await widget.onReady(identity);
    } catch (error) {
      if (mounted) {
        setState(() {
          message = error is ManagerAuthException
              ? error.code
              : 'cloudSetupFailed';
          failure = true;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: NcAuthLayout(
      child: NcCard(
        title: context.t('cloudFirstSetup'),
        children: [
          Text(context.t('cloudFirstSetupHelp')),
          Form(
            key: form,
            child: Column(
              children: [
                NcField(
                  label: context.t('managerName'),
                  controller: name,
                  enabled: !busy,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.t('requiredField')
                      : null,
                ),
                const SizedBox(height: 12),
                NcField(
                  label: context.t('username'),
                  controller: username,
                  enabled: !busy,
                  hint: context.t('usernameHint'),
                  validator: (v) =>
                      RegExp(r'^[a-z0-9_]{3,32}$')
                          .hasMatch(v?.trim().toLowerCase() ?? '')
                      ? null
                      : context.t('usernameHint'),
                ),
                const SizedBox(height: 12),
                NcField(
                  label: context.t('email'),
                  controller: email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null &&
                          RegExp(r'^[^ @]+@[^ @]+\.[^ @]+$').hasMatch(v.trim())
                      ? null
                      : context.t('invalidEmail'),
                ),
                const SizedBox(height: 12),
                NcField(
                  label: context.t('password'),
                  controller: password,
                  enabled: !busy,
                  obscure: true,
                  validator: (v) => (v?.length ?? 0) >= 12
                      ? null
                      : context.t('securePasswordHint'),
                ),
              ],
            ),
          ),
          if (message != null)
            NcNotice(
              title: context.t(message!),
              tone: failure ? NoticeTone.danger : NoticeTone.warning,
            ),
          NcButton(
            label: context.t('createFirstManager'),
            onPressed: () => submit(false),
            busy: busy,
          ),
          NcButton(
            label: context.t('activateVerifiedManager'),
            secondary: true,
            onPressed: () => submit(true),
            busy: busy,
          ),
        ],
      ),
    ),
  );
}
