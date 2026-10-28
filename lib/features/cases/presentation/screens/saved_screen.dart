import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) => NcPageColumn(
    maxWidth: 800,
    children: [
      NcCard(
        title: context.t('saved'),
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Color(0xFF398B98),
          ),
          NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
        ],
      ),
      NcButton(
        label: context.t('newCase'),
        onPressed: () => context.read<AppCubit>().navigate(AppPage.insideCase),
      ),
      NcButton(
        label: context.t('returnShift'),
        secondary: true,
        onPressed: () => context.read<AppCubit>().navigate(AppPage.activeShift),
      ),
    ],
  );
}
