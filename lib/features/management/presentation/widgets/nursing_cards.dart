import '../../../../core/widgets/nc_detail_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../analytics/presentation/widgets/analytics_sections.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/managed_record_kind.dart';
import 'record_actions.dart';

class NursingCards extends StatelessWidget {
  const NursingCards({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final summary = summaryFor(context);
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1000
            ? 3
            : c.maxWidth >= 620
            ? 2
            : 1;
        final width = (c.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final n in data.staff.where((n) => n.active))
              SizedBox(
                width: width,
                child: NcCard(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.tealLight,
                          child: Text(n.name.characters.first),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => NcDetailPage.open(
                                  context,
                                  tag: 'nursing-${n.id}',
                                  title: n.name,
                                  child: NcCard(
                                    children: [
                                      Text(
                                        context.t(
                                          n.isManager ? 'manager' : 'nursing',
                                        ),
                                      ),
                                      Text(
                                        '${context.t('monthlySalary')}: ${context.money(n.salaryMinor)}',
                                      ),
                                      if (n.phone.isNotEmpty) Text(n.phone),
                                      Text(
                                        '${context.t('cases')}: ${data.cases.where((c) => c.staffId == n.id).length}',
                                      ),
                                      RecordActions(
                                        kind: ManagedRecordKind.nursing,
                                        id: n.id,
                                      ),
                                    ],
                                  ),
                                ),
                                child: NcHeroTitle(
                                  tag: 'nursing-${n.id}',
                                  title: n.name,
                                ),
                              ),
                              Text(
                                context.t(n.isManager ? 'manager' : 'nursing'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${context.t('monthlySalary')}: ${context.money(n.salaryMinor)}',
                    ),
                    if (n.phone.isNotEmpty)
                      Text('${context.t('phoneOptional')}: ${n.phone}'),
                    Text(
                      '${context.t('cases')}: ${summary.cases.where((c) => c.staffId == n.id).length}',
                    ),
                    Text(
                      '${context.t('advanceTotal')}: ${context.money(summary.movements.where((m) => m.staffId == n.id && m.kind == CashKind.advance).fold<int>(0, (s, m) => s + m.amountMinor))}',
                    ),
                    Text(
                      '${context.t('awardsTotal')}: ${context.money(summary.movements.where((m) => m.staffId == n.id && m.kind == CashKind.award).fold<int>(0, (s, m) => s + m.amountMinor))}',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.t('active'),
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontSize: 11,
                          ),
                        ),
                        RecordActions(
                          kind: ManagedRecordKind.nursing,
                          id: n.id,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
