import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../management/presentation/widgets/management_form_dialog.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/lab_test.dart';
import '../cubit/laboratory_cubit.dart';
import 'lab_test_editor.dart';

class LabCatalogue extends StatefulWidget {
  const LabCatalogue({super.key});

  @override
  State<LabCatalogue> createState() => _LabCatalogueState();
}

class _LabCatalogueState extends State<LabCatalogue> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final allTests = data.labTests.where((t) => t.active).toList();
    final tests = search.trim().isEmpty
        ? allTests
        : allTests
              .where(
                (t) =>
                    t.name.toLowerCase().contains(search.trim().toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NcActionRow(
          children: [
            NcButton(
              label: context.t('addLabTest'),
              icon: Icons.add,
              onPressed: () => ManagementFormDialog.open(
                context,
                (dialogCtx) => BlocProvider.value(
                  value: context.read<LaboratoryCubit>(),
                  child: LabTestEditor(onSaved: () => Navigator.pop(dialogCtx)),
                ),
              ),
            ),
          ],
        ),
        NcCard(
          title: context.t('labCatalogue'),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: context.t('search'),
                prefixIcon: const Icon(Icons.search, size: 18),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
            const SizedBox(height: 12),
            if (allTests.isEmpty)
              NcEmpty(message: context.t('noLabTests'))
            else if (tests.isEmpty)
              NcEmpty(message: context.t('noResults'))
            else
              NcAdaptiveTable(
                headers: [context.t('itemName'), context.t('price')],
                emptyLabel: context.t('noResults'),
                columnWidths: const [300, 140],
                rows: List.generate(tests.length, (i) => List.filled(2, '')),
                cellBuilder: (rowIdx, colIdx, val) {
                  final test = tests[rowIdx];
                  if (colIdx == 0) {
                    return Text(
                      test.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  return Text(
                    '${(test.priceMinor / 100).toStringAsFixed(2)} ${context.t('currency')}',
                  );
                },
                actions: (rowIdx) {
                  final test = tests[rowIdx];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: context.t('edit'),
                        onPressed: () => ManagementFormDialog.open(
                          context,
                          (dialogCtx) => BlocProvider.value(
                            value: context.read<LaboratoryCubit>(),
                            child: LabTestEditor(
                              initial: test,
                              onSaved: () => Navigator.pop(dialogCtx),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.archive_outlined, size: 18),
                        tooltip: context.t('archive'),
                        onPressed: () => _confirmArchive(context, test),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  void _confirmArchive(BuildContext context, LabTest test) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.t('archiveLabTest')),
        content: Text('${context.t('confirmArchive')} (${test.name})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.t('cancel')),
          ),
          NcButton(
            label: context.t('archive'),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context.read<LaboratoryCubit>().archiveTest(test.id);
            },
          ),
        ],
      ),
    );
  }
}
