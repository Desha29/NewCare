import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../screens/case_form_screen.dart';

class AddCaseDialog extends StatelessWidget {
  const AddCaseDialog({super.key});
  static Future<bool?> open(BuildContext context) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AddCaseDialog(),
  );
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 760,
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('addCase'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: context.t('close'),
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: CaseFormScreen(
                  outside: false,
                  inDialog: true,
                  onSaved: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
