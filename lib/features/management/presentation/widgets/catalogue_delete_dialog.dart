import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/action_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_toast.dart';

class CatalogueDeleteDialog extends StatelessWidget {
  const CatalogueDeleteDialog({
    super.key,
    required this.title,
    required this.name,
    required this.detail,
    required this.action,
    required this.onDelete,
  });
  final String title, name, detail;
  final ActionCubit action;
  final Future<bool> Function() onDelete;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String name,
    required String detail,
    required ActionCubit action,
    required Future<bool> Function() onDelete,
  }) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CatalogueDeleteDialog(
        title: title,
        name: name,
        detail: detail,
        action: action,
        onDelete: onDelete,
      ),
    );
    if (deleted == true && context.mounted) {
      NcToast.show(
        context,
        message: context.t('recordDeleted'),
        tone: NcToastTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ActionCubit, ActionState>(
    bloc: action,
    builder: (context, state) => PopScope(
      canPop: !state.busy,
      child: AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(detail),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              NcNotice(title: context.t(state.error!), tone: NoticeTone.danger),
            ],
          ],
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: state.busy ? null : () => Navigator.pop(context, false),
            child: Text(context.t('cancel')),
          ),
          NcButton(
            label: context.t('delete'),
            busy: state.busy,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: state.busy
                ? null
                : () async {
                    final deleted = await onDelete();
                    if (deleted && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
          ),
        ],
      ),
    ),
  );
}
