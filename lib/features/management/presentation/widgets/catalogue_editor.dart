import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../cubit/management_cubit.dart';

class CatalogueEditor extends StatefulWidget {
  const CatalogueEditor({super.key, this.onSaved});
  final VoidCallback? onSaved;
  @override
  State<CatalogueEditor> createState() => _CatalogueEditorState();
}

class _CatalogueEditorState extends State<CatalogueEditor> {
  final form = GlobalKey<FormState>();
  final ar = TextEditingController();
  @override
  void dispose() {
    ar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('procedure'),
      children: [
        const OperationError<ManagementCubit>(),
        NcField(
          label: context.t('itemName'),
          hint: context.t('procedureNameHint'),
          controller: ar,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        NcButton(
          label: context.t('add'),
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            final cubit = context.read<ManagementCubit>();
            final success = await cubit.addProcedure(
              Procedure(
                id: const Uuid().v4(),
                nameAr: ar.text.trim(),
                nameEn: ar.text.trim(),
              ),
            );
            if (success && context.mounted) {
              ar.clear();
              widget.onSaved?.call();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(context.t('added'))));
            }
          },
        ),
      ],
    ),
  );
}
