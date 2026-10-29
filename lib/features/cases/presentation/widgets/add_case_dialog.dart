import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../../../../core/localization/localization_extensions.dart';
import '../screens/case_form_screen.dart';
import '../../data/models/case_record.dart';

class AddCaseDialog extends StatelessWidget {
  const AddCaseDialog({super.key, this.initial});
  final CaseRecord? initial;
  static Future<bool?> open(BuildContext context, {CaseRecord? initial}) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddCaseDialog(initial: initial),
      );
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    clipBehavior: Clip.antiAlias,
    insetPadding: const EdgeInsets.all(20),
    child: SizedBox(
      width: math.min(1000, MediaQuery.sizeOf(context).width - 40),
      height: math.min(820, MediaQuery.sizeOf(context).height * .9),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t(initial == null ? 'addCase' : 'edit'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t('caseFormSubtitle'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.t('close'),
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 12),
              ],
            ),
            Expanded(
              child: CaseFormScreen(
                outside: initial?.location == CaseLocation.outside,
                inDialog: true,
                initial: initial,
                onSaved: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
