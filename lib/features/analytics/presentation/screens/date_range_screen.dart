import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../widgets/period_filter.dart';

class DateRangeScreen extends StatelessWidget {
  const DateRangeScreen({super.key});
  @override
  Widget build(BuildContext context) => NcPageColumn(
    maxWidth: 800,
    children: [
      NcCard(title: context.t('dateRange'), children: const [PeriodFilter()]),
      NcButton(
        label: context.t('apply'),
        onPressed: () => context.read<AppCubit>().navigate(AppPage.overview),
      ),
      NcButton(
        label: context.t('cancel'),
        secondary: true,
        onPressed: () => context.read<AppCubit>().navigate(AppPage.overview),
      ),
    ],
  );
}
