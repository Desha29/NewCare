import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../management/data/managed_record_kind.dart';
import '../../../management/presentation/widgets/record_actions.dart';
import '../../data/models/case_record.dart';

class CaseCardGrid extends StatelessWidget {
  const CaseCardGrid({
    super.key,
    required this.records,
    required this.workspace,
    this.editable = false,
  });
  final List<CaseRecord> records;
  final WorkspaceSnapshot workspace;
  final bool editable;
  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return NcEmpty(message: context.t('noResults'));
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1080
            ? 8
            : ((c.maxWidth + 10) / 140).floor().clamp(1, 8);
        final width = (c.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final r in records)
              SizedBox(
                key: ValueKey('case-card-${r.id}'),
                width: width,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => context.read<AppCubit>().selectCase(r.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            r.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _owner(context, r),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (workspace.staff.any(
                            (n) => n.id == r.staffId && n.isManager,
                          ))
                            Text(
                              context.t('manager'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                              ),
                            ),
                          NcStatusBadge(r.location.name),
                          const SizedBox(height: 6),
                          Text(
                            context.money(r.amountMinor),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          NcStatusBadge(r.payment.name),
                          const SizedBox(height: 6),
                          Text(
                            context.time(r.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                          if (editable)
                            RecordActions(
                              kind: ManagedRecordKind.caseRecord,
                              id: r.id,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _owner(BuildContext context, CaseRecord r) {
    final n = workspace.staff.where((n) => n.id == r.staffId).firstOrNull;
    return n?.name ?? r.staffId;
  }
}
