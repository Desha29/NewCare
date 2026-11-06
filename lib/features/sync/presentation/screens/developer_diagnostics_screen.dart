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
import '../../../../app/navigation/app_page.dart';
import '../../data/models/reconciliation.dart';
import '../../data/repositories/cloud_sync_service.dart';

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
        sync: context.read<CloudSyncService?>(),
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
            if (!context.read<AppCubit>().cloudAuthentication)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(context.t('resetWorkspaceTitle')),
                      content: Text(context.t('resetWorkspaceConfirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(context.t('cancel')),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.danger,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(context.t('confirmReset')),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<WorkspaceRepository>().resetWorkspace();
                    if (context.mounted) {
                      context.read<AppCubit>().navigate(AppPage.setup);
                    }
                  }
                },
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: Text(context.t('resetAndStartSetup')),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.status == ReconciliationStatus.matched
                ? AppColors.tealLight
                : AppColors.warningBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.t(
              state.failed
                  ? 'storageFailed'
                  : state.loading
                  ? 'syncing'
                  : switch (state.status) {
                      ReconciliationStatus.unconfigured => 'syncNotConfigured',
                      ReconciliationStatus.unavailable =>
                        'syncVerificationUnavailable',
                      ReconciliationStatus.pending => 'syncVerificationPending',
                      ReconciliationStatus.different =>
                        'syncVerificationDifferent',
                      ReconciliationStatus.matched => 'syncVerificationMatched',
                    },
            ),
            style: TextStyle(
              color: state.status == ReconciliationStatus.matched
                  ? AppColors.navy
                  : AppColors.warning,
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
                        DataCell(
                          Text(
                            state.remoteCounts[entry.key] == null
                                ? '—'
                                : NumberFormat.decimalPattern(
                                    Localizations.localeOf(context)
                                        .languageCode,
                                  ).format(state.remoteCounts[entry.key]),
                          ),
                        ),
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
