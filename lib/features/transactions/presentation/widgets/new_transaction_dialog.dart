import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../drawer/presentation/widgets/movement_form.dart';

class NewTransactionDialog extends StatelessWidget {
  const NewTransactionDialog({super.key});
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
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
              const MovementForm(allowAdvances: true, managerMode: true),
            ],
          ),
        ),
      ),
    ),
  );
}
