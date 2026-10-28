import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../data/managed_record_kind.dart';
import '../models/record_editor_spec.dart';
import '../cubit/management_cubit.dart';
import 'record_editor_field.dart';

class RecordEditorDialog extends StatefulWidget {
  const RecordEditorDialog({
    super.key,
    required this.kind,
    required this.id,
    required this.spec,
  });
  final ManagedRecordKind kind;
  final String id;
  final RecordEditorSpec spec;
  @override
  State<RecordEditorDialog> createState() => _RecordEditorDialogState();
}

class _RecordEditorDialogState extends State<RecordEditorDialog> {
  final form = GlobalKey<FormState>(), reason = TextEditingController();
  late final Map<String, TextEditingController> controllers;
  @override
  void initState() {
    super.initState();
    controllers = {
      for (final f in widget.spec.fields)
        f.key: TextEditingController(text: f.initial),
    };
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  Map<String, dynamic> _values() => {
    for (final f in widget.spec.fields)
      f.key: switch (f.input) {
        EditorInput.money => Money.parse(controllers[f.key]!.text),
        EditorInput.toggle => controllers[f.key]!.text == 'true',
        EditorInput.multiline when f.key == 'supplies' =>
          controllers[f.key]!.text
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        EditorInput.dateTime =>
          controllers[f.key]!.text.isEmpty ? null : controllers[f.key]!.text,
        _ => controllers[f.key]!.text.trim(),
      },
  };
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 620,
        maxHeight: MediaQuery.sizeOf(context).height * .86,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${context.t('edit')} · ${widget.spec.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                const OperationError<ManagementCubit>(),
                for (final field in widget.spec.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RecordEditorField(
                      field: field,
                      controller: controllers[field.key]!,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                if (widget.spec.requiresReason)
                  NcField(
                    label: context.t('changeReason'),
                    controller: reason,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? context.t('reasonRequired')
                        : null,
                  ),
                const SizedBox(height: 20),
                NcActionRow(
                  children: [
                    NcButton(
                      label: context.t('save'),
                      busy: context.watch<ManagementCubit>().state.busy,
                      onPressed: () async {
                        if (!form.currentState!.validate()) return;
                        if (await context.read<ManagementCubit>().updateRecord(
                              widget.kind,
                              widget.id,
                              _values(),
                              widget.spec.requiresReason
                                  ? reason.text.trim()
                                  : context.t('recordUpdated'),
                            ) &&
                            context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                    NcButton(
                      label: context.t('cancel'),
                      secondary: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
