import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/storage/string_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../cubit/diagnostics_cubit.dart';

class DeveloperDiagnosticsScreen extends StatelessWidget {
  const DeveloperDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppCubit>();
    if (!app.state.managerUnlocked ||
        (app.cloudAuthentication &&
            app.managerIdentity?.viewDiagnostics != true)) {
      return Center(child: Text(context.t('managerRequired')));
    }
    return BlocProvider(
      create: (_) => DiagnosticsCubit(
        context.read<WorkspaceRepository>(),
        context.read<StringStore>(),
        () =>
            app.state.managerUnlocked &&
            (!app.cloudAuthentication ||
                app.managerIdentity?.viewDiagnostics == true),
      )..refresh(),
      child: const _DiagnosticsContent(),
    );
  }
}

class _DiagnosticsContent extends StatelessWidget {
  const _DiagnosticsContent();
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DiagnosticsCubit, DiagnosticsState>(
    builder: (context, state) => NcCard(
      title: context.t('developerDiagnostics'),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.navy),
            Text(context.t('diagnosticsManagerOnly')),
            OutlinedButton.icon(
              onPressed: state.loading
                  ? null
                  : context.read<DiagnosticsCubit>().refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.t('diagnosticsRefresh')),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.t(state.failed ? 'storageFailed' : 'syncNotConfigured'),
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(context.t('diagnosticsVerificationHelp')),
        if (state.pending != null)
          Text(
            '${context.t('diagnosticsPending')}: ${NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(state.pending)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: [
                  DataColumn(label: Text(context.t('diagnosticsDataset'))),
                  DataColumn(label: Text(context.t('diagnosticsLocal'))),
                  DataColumn(label: Text(context.t('diagnosticsCloud'))),
                ],
                rows: [
                  for (final entry in state.localCounts.entries)
                    DataRow(
                      cells: [
                        DataCell(Text(context.t(entry.key))),
                        DataCell(
                          Text(
                            NumberFormat.decimalPattern(
                              Localizations.localeOf(context).languageCode,
                            ).format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const DataCell(Text('—')),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (state.checkedAt != null)
          Text(
            '${context.t('diagnosticsLocalCheckedAt')}: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).add_Hm().format(state.checkedAt!)}',
          ),
      ],
    ),
  );
}
