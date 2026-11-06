import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum NcToastTone { success, error, warning, info }

abstract final class NcToast {
  static void show(
    BuildContext context, {
    required String message,
    NcToastTone tone = NcToastTone.info,
    String? title,
  }) {
    final type = switch (tone) {
      NcToastTone.success => ToastificationType.success,
      NcToastTone.error => ToastificationType.error,
      NcToastTone.warning => ToastificationType.warning,
      NcToastTone.info => ToastificationType.info,
    };
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: title == null ? null : Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      direction: Directionality.of(context),
      alignment: Directionality.of(context) == TextDirection.rtl
          ? Alignment.topLeft
          : Alignment.topRight,
      showProgressBar: true,
      closeOnClick: true,
      dragToClose: true,
    );
  }
}
