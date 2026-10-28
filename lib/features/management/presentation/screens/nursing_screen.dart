import 'package:flutter/material.dart';

import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../widgets/nursing_editor.dart';
import '../widgets/nursing_cards.dart';
import '../widgets/management_form_dialog.dart';

class NursingScreen extends StatelessWidget {
  const NursingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final summary = summaryFor(context);
    return NcPageColumn(
      children: [
        const PeriodFilter(),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: NcButton(
            label: context.t('addNursing'),
            icon: Icons.add,
            onPressed: () => ManagementFormDialog.open(
              context,
              (dialogContext) =>
                  NursingEditor(onSaved: () => Navigator.pop(dialogContext)),
            ),
          ),
        ),
        const NursingCards(),
        StaffCasesChart(summary: summary),
      ],
    );
  }
}
