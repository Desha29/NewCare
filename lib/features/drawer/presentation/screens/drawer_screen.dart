import '../widgets/movement_labels.dart';
import '../widgets/drawer_handover_panel.dart';
import '../widgets/drawer_handover_button.dart';
import '../widgets/drawer_balance_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_signed_money.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/movement_form.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});
  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final movements = data.movements;
    return NcPageColumn(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final form = MovementForm(
              key: formKey,
              allowAdvances: true,
              allowIncome: false,
            );
            const status = NcPageColumn(
              children: [DrawerBalanceCard(), DrawerHandoverButton()],
            );
            return constraints.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: form),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: status),
                    ],
                  )
                : NcPageColumn(children: [form, status]);
          },
        ),
        if (data.handovers.isNotEmpty) const DrawerHandoverHistory(),
        if (movements.isNotEmpty)
          NcCard(
            title: context.t('latestActivity'),
            children: [
              for (final m in movements.reversed.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(movementDescription(context, m)),
                  subtitle: Text(movementCategory(context, m)),
                  trailing: NcSignedMoney(m.signedMinor),
                ),
            ],
          ),
      ],
    );
  }
}
