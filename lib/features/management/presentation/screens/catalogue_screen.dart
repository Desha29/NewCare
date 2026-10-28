import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/catalogue_editor.dart';
import '../widgets/record_actions.dart';
import '../../data/managed_record_kind.dart';
import '../widgets/management_form_dialog.dart';

class CatalogueScreen extends StatelessWidget {
  const CatalogueScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final procedures = data.procedures.where((p) => p.active).toList();
    return NcPageColumn(
      maxWidth: 1000,
      children: [
        NcActionRow(
          children: [
            NcButton(
              label: context.t('addProcedure'),
              icon: Icons.add,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogContext) => CatalogueEditor(
                  onSaved: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
            NcButton(
              label: context.t('addSupply'),
              icon: Icons.add,
              secondary: true,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogContext) => CatalogueEditor(
                  supply: true,
                  onSaved: () => Navigator.pop(dialogContext),
                ),
              ),
            ),
          ],
        ),
        NcCard(
          title: context.t('catalogue'),
          children: [
            if (data.procedures.isEmpty)
              NcEmpty(message: context.t('emptyCatalogue')),
            NcAdaptiveTable(
              headers: [context.t('procedure'), context.t('defaultPrice')],
              rows: procedures
                  .map((p) => [p.nameAr, context.money(p.priceMinor)])
                  .toList(),
              actions: (i) => RecordActions(
                kind: ManagedRecordKind.procedure,
                id: procedures[i].id,
              ),
              emptyLabel: context.t('emptyCatalogue'),
            ),
          ],
        ),
        NcCard(
          title: context.t('supplies'),
          children: [
            if (data.supplies.isEmpty) NcEmpty(message: context.t('noResults')),
            for (final s in data.supplies)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(s.nameAr),
                trailing: RecordActions(
                  kind: ManagedRecordKind.supply,
                  id: s.id,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
