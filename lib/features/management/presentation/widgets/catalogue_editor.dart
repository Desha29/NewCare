import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../catalogue/data/models/supply_item.dart';
import '../cubit/management_cubit.dart';

class CatalogueEditor extends StatefulWidget {
  const CatalogueEditor({super.key, this.supply = false});
  final bool supply;
  @override
  State<CatalogueEditor> createState() => _CatalogueEditorState();
}

class _CatalogueEditorState extends State<CatalogueEditor> {
  final form = GlobalKey<FormState>();
  final ar = TextEditingController(),
      en = TextEditingController(),
      price = TextEditingController();
  @override
  void dispose() {
    ar.dispose();
    en.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t(widget.supply ? 'supplies' : 'procedure'),
      children: [
        const OperationError<ManagementCubit>(),
        NcField(
          label: context.t('procedureNameAr'),
          controller: ar,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        NcField(
          label: context.t('procedureNameEn'),
          controller: en,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.t('requiredField') : null,
        ),
        if (!widget.supply)
          NcField(
            label: context.t('defaultPrice'),
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              try {
                Money.parse(v ?? '');
                return null;
              } catch (_) {
                return context.t('invalidAmount');
              }
            },
          ),
        NcButton(
          label: context.t('add'),
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            final cubit = context.read<ManagementCubit>();
            final success = widget.supply
                ? await cubit.addSupply(
                    SupplyItem(
                      id: const Uuid().v4(),
                      nameAr: ar.text.trim(),
                      nameEn: en.text.trim(),
                    ),
                  )
                : await cubit.addProcedure(
                    Procedure(
                      id: const Uuid().v4(),
                      nameAr: ar.text.trim(),
                      nameEn: en.text.trim(),
                      priceMinor: Money.parse(price.text),
                    ),
                  );
            if (success && context.mounted) {
              ar.clear();
              en.clear();
              price.clear();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(context.t('added'))));
            }
          },
        ),
      ],
    ),
  );
}
