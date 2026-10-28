import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/managed_record_kind.dart';
import '../models/record_editor_specs.dart';
import 'record_editor_dialog.dart';
import 'delete_record_dialog.dart';

class RecordActions extends StatelessWidget {
  const RecordActions({super.key, required this.kind, required this.id});
  final ManagedRecordKind kind;
  final String id;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: context.t('edit'),
        icon: const Icon(Icons.edit_outlined, size: 18),
        onPressed: () => _open(context, 'edit'),
      ),
      IconButton(
        tooltip: context.t(
          kind == ManagedRecordKind.shift ? 'archiveShift' : 'delete',
        ),
        color: Theme.of(context).colorScheme.error,
        icon: Icon(
          kind == ManagedRecordKind.shift
              ? Icons.archive_outlined
              : Icons.delete_outline,
          size: 18,
        ),
        onPressed: () => _open(context, 'delete'),
      ),
    ],
  );

  Future<void> _open(BuildContext context, String action) async {
    if (!context.read<AppCubit>().state.managerUnlocked) return;
    final spec = RecordEditorSpecs.create(
      context,
      context.read<WorkspaceCubit>().state,
      kind,
      id,
    );
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => action == 'edit'
          ? RecordEditorDialog(kind: kind, id: id, spec: spec)
          : DeleteRecordDialog(kind: kind, id: id, title: spec.title),
    );
    if ((changed ?? false) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(action == 'edit' ? 'recordUpdated' : 'recordDeleted'),
          ),
        ),
      );
    }
  }
}
