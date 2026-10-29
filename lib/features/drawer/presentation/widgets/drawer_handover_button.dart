import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_button.dart';
import 'drawer_handover_panel.dart';

class DrawerHandoverButton extends StatelessWidget {
  const DrawerHandoverButton({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: NcButton(
      label: context.t('drawerHandover'),
      icon: Icons.swap_horiz,
      iconSize: 24,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => DrawerHandoverPanel.open(context),
    ),
  );
}
