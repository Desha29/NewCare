import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../data/models/lab_test.dart';
import '../cubit/laboratory_cubit.dart';

class LabTestEditor extends StatefulWidget {
  const LabTestEditor({super.key, this.initial, this.onSaved});
  final LabTest? initial;
  final VoidCallback? onSaved;

  @override
  State<LabTestEditor> createState() => _LabTestEditorState();
}

class _LabTestEditorState extends State<LabTestEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initial?.name ?? '');
    priceController = TextEditingController(
      text: widget.initial != null
          ? (widget.initial!.priceMinor / 100).toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Form(
      key: form,
      child: NcCard(
        title: isEdit ? context.t('editLabTest') : context.t('addLabTest'),
        children: [
          const OperationError<LaboratoryCubit>(),
          NcField(
            label: context.t('itemName'),
            controller: nameController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? context.t('requiredField') : null,
          ),
          NcField(
            label: context.t('price'),
            hint: context.t('priceHint'),
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.t('requiredField');
              final parsed = double.tryParse(v);
              if (parsed == null || parsed < 0) return context.t('invalidAmount');
              return null;
            },
          ),
          const SizedBox(height: 8),
          NcButton(
            label: isEdit ? context.t('save') : context.t('add'),
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              final cubit = context.read<LaboratoryCubit>();
              final priceEgp = double.parse(priceController.text.trim());
              final priceMinor = (priceEgp * 100).round();
              final test = widget.initial == null
                  ? LabTest(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      priceMinor: priceMinor,
                    )
                  : widget.initial!.copyWith(
                      name: nameController.text.trim(),
                      priceMinor: priceMinor,
                    );
              final success = await cubit.saveTest(test);
              if (success && mounted) {
                widget.onSaved?.call();
              }
            },
          ),
        ],
      ),
    );
  }
}

