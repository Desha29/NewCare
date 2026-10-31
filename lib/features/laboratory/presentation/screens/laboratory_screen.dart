import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_tabs.dart';
import '../../../management/presentation/widgets/management_form_dialog.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/laboratory_cubit.dart';
import '../widgets/lab_catalogue.dart';
import '../widgets/lab_order_form.dart';
import '../widgets/lab_order_table.dart';

class LaboratoryScreen extends StatelessWidget {
  const LaboratoryScreen({super.key, this.isManager = false});
  final bool isManager;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LaboratoryCubit(ctx.read<WorkspaceRepository>()),
      child: _LaboratoryView(isManager: isManager),
    );
  }
}

class _LaboratoryView extends StatefulWidget {
  const _LaboratoryView({required this.isManager});
  final bool isManager;

  @override
  State<_LaboratoryView> createState() => _LaboratoryViewState();
}

class _LaboratoryViewState extends State<_LaboratoryView> {
  int tabIndex = 0;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final allOrders = data.labOrders;
    final filteredOrders = search.trim().isEmpty
        ? allOrders
        : allOrders
            .where((o) => o.patientName
                .toLowerCase()
                .contains(search.trim().toLowerCase()))
            .toList();

    return NcPageColumn(
      maxWidth: 1000,
      children: [
        if (widget.isManager) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NcTabs<int>(
              selected: tabIndex,
              maxWidth: 360,
              items: [
                NcTabItem(
                  value: 0,
                  label: context.t('labOrders'),
                  icon: Icons.receipt_long_outlined,
                ),
                NcTabItem(
                  value: 1,
                  label: context.t('labCatalogue'),
                  icon: Icons.biotech_outlined,
                ),
              ],
              onChanged: (idx) => setState(() => tabIndex = idx),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (!widget.isManager || tabIndex == 0) ...[
          NcActionRow(
            children: [
              NcButton(
                label: context.t('newLabOrder'),
                icon: Icons.add,
                onPressed: () => ManagementFormDialog.open(
                  context,
                  (dialogCtx) => BlocProvider.value(
                    value: context.read<LaboratoryCubit>(),
                    child: LabOrderForm(
                      onSaved: () => Navigator.pop(dialogCtx),
                    ),
                  ),
                ),
              ),
            ],
          ),
          NcCard(
            title: context.t('labOrders'),
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
              if (allOrders.isEmpty)
                NcEmpty(message: context.t('noLabOrders'))
              else if (filteredOrders.isEmpty)
                NcEmpty(message: context.t('noResults'))
              else
                LabOrderTable(orders: filteredOrders.reversed.toList()),
            ],
          ),
        ] else ...[
          const LabCatalogue(),
        ],
      ],
    );
  }
}
