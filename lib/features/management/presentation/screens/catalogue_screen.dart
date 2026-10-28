import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../widgets/catalogue_editor.dart';

class CatalogueScreen extends StatelessWidget {
  const CatalogueScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final locale = Localizations.localeOf(context).languageCode;
    return NcPageColumn(
      maxWidth: 1000,
      children: [
        NcCard(
          title: context.t('catalogue'),
          children: [
            if (data.procedures.isEmpty)
              NcEmpty(message: context.t('emptyCatalogue')),
            for (final p in data.procedures)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medical_services_outlined),
                title: Text(p.name(locale)),
                trailing: Text(context.money(p.priceMinor)),
              ),
          ],
        ),
        const CatalogueEditor(),
        NcCard(
          title: context.t('supplies'),
          children: [
            if (data.supplies.isEmpty) NcEmpty(message: context.t('noResults')),
            for (final s in data.supplies)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(s.name(locale)),
              ),
          ],
        ),
        const CatalogueEditor(supply: true),
      ],
    );
  }
}
