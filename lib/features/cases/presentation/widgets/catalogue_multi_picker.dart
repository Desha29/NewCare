import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class CatalogueOption {
  const CatalogueOption(this.id, this.name, this.priceMinor);
  final String id, name;
  final int priceMinor;
}

class CatalogueMultiPicker extends StatefulWidget {
  const CatalogueMultiPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.required = false,
    this.compact = false,
  });
  final String label;
  final List<CatalogueOption> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool required;
  final bool compact;
  @override
  State<CatalogueMultiPicker> createState() => _CatalogueMultiPickerState();
}

class _CatalogueMultiPickerState extends State<CatalogueMultiPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final label = widget.label,
        selected = widget.selected,
        required = widget.required,
        onChanged = widget.onChanged;
    final options = widget.options
        .where((o) => o.name.toLowerCase().contains(query.trim().toLowerCase()))
        .toList();
    return FormField<Set<String>>(
      initialValue: selected,
      validator: (_) =>
          required && selected.isEmpty ? context.t('procedureRequired') : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                '${selected.length}',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.compact ? 6 : 8),
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: context.t('searchCatalogue'),
              isDense: widget.compact,
              contentPadding: widget.compact
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                  : null,
              prefixIconConstraints: widget.compact
                  ? const BoxConstraints(minWidth: 34)
                  : null,
              prefixIcon: const Icon(Icons.search, size: 18),
            ),
          ),
          SizedBox(height: widget.compact ? 6 : 8),
          if (query.isNotEmpty && selected.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final o in widget.options.where(
                  (o) => selected.contains(o.id),
                ))
                  InputChip(
                    label: Text(o.name),
                    onDeleted: () => onChanged({...selected}..remove(o.id)),
                  ),
              ],
            ),
          if (options.isEmpty)
            Text(
              context.t('noResults'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.compact ? 120 : 200),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in options)
                    FilterChip(
                      label: Text(
                        option.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      selected: selected.contains(option.id),
                      visualDensity: widget.compact
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                      materialTapTargetSize:
                          widget.compact &&
                              MediaQuery.sizeOf(context).width >= 720
                          ? MaterialTapTargetSize.shrinkWrap
                          : MaterialTapTargetSize.padded,
                      selectedColor: AppColors.tealLight,
                      onSelected: (on) {
                        final next = {...selected};
                        if (on) {
                          next.add(option.id);
                        } else {
                          next.remove(option.id);
                        }
                        field.didChange(next);
                        onChanged(next);
                      },
                    ),
                ],
              ),
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                field.errorText!,
                style: const TextStyle(color: AppColors.danger, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
