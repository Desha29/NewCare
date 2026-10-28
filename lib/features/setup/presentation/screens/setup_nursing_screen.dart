import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../../../management/presentation/widgets/nursing_editor.dart';

class SetupNursingScreen extends StatelessWidget {
  const SetupNursingScreen({super.key});
  @override
  Widget build(BuildContext context) => NcPageColumn(
    maxWidth: 900,
    children: [
      const NursingEditor(),
      const NursingListPanel(),
      NcButton(
        label: context.t('continueAction'),
        onPressed: () =>
            context.read<AppCubit>().navigate(AppPage.setupCatalogue),
      ),
    ],
  );
}
