import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// Shared dialog shell for adding and updating manager records.
class ManagementFormDialog extends StatelessWidget {
  const ManagementFormDialog({super.key, required this.child});
  final Widget child;
  static Future<void> open(BuildContext context, WidgetBuilder form) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) =>
            ManagementFormDialog(child: form(dialogContext)),
      );
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  tooltip: context.t('close'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
