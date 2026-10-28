import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    return NcPageColumn(
      children: [
        NcNotice(
          title: context.t('pendingSync'),
          detail: context.t('syncNote'),
          tone: NoticeTone.warning,
        ),
        NcCard(
          title: '${context.t('queue')} · ${data.audit.length}',
          children: [
            if (data.audit.isEmpty) NcEmpty(message: context.t('noAudit')),
            for (final entry in data.audit.reversed.take(50))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, size: 18),
                title: Text(context.t(entry.action)),
                subtitle: Text(
                  '${context.date(entry.at)} · ${context.time(entry.at)}${entry.reason.isEmpty ? '' : '\n${context.t('changeReason')}: ${entry.reason}'}',
                ),
                trailing: Text(
                  context.t('queueLocal'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        NcNotice(title: context.t('noConflict')),
      ],
    );
  }
}
