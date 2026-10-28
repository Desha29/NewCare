import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../data/managed_record_kind.dart';
import '../cubit/management_cubit.dart';

class DeleteRecordDialog extends StatefulWidget {
  const DeleteRecordDialog({
    super.key,
    required this.kind,
    required this.id,
    required this.title,
  });
  final ManagedRecordKind kind;
  final String id, title;
  @override
  State<DeleteRecordDialog> createState() => _DeleteRecordDialogState();
}

class _DeleteRecordDialogState extends State<DeleteRecordDialog> {
  final reason = TextEditingController(), form = GlobalKey<FormState>();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      context.t(
        widget.kind == ManagedRecordKind.shift
            ? 'archiveShift'
            : 'confirmDelete',
      ),
    ),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title),
              const SizedBox(height: 16),
              NcNotice(
                title: context.t('deleteNote'),
                tone: NoticeTone.warning,
              ),
              const SizedBox(height: 16),
              const OperationError<ManagementCubit>(),
              NcField(
                label: context.t('changeReason'),
                controller: reason,
                validator: (v) => v == null || v.trim().isEmpty
                    ? context.t('reasonRequired')
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(context.t('cancel')),
      ),
      NcButton(
        label: context.t(
          widget.kind == ManagedRecordKind.shift ? 'archiveShift' : 'delete',
        ),
        busy: context.watch<ManagementCubit>().state.busy,
        onPressed: () async {
          if (!form.currentState!.validate()) return;
          if (await context.read<ManagementCubit>().deleteRecord(
                widget.kind,
                widget.id,
                reason.text.trim(),
              ) &&
              context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
    ],
  );
}
