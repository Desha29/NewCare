import 'package:flutter/material.dart';

import '../../../../core/utils/center_clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_field.dart';
import '../models/record_editor_spec.dart';

class RecordEditorField extends StatelessWidget {
  const RecordEditorField({
    super.key,
    required this.field,
    required this.controller,
    required this.onChanged,
  });
  final EditorField field;
  final TextEditingController controller;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) {
    if (field.input == EditorInput.toggle) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        value: controller.text == 'true',
        onChanged: (v) {
          controller.text = v.toString();
          onChanged();
        },
      );
    }
    if (field.input == EditorInput.choice) {
      return NcSelect<String>(
        label: field.label,
        value: field.choices.containsKey(controller.text)
            ? controller.text
            : null,
        items: field.choices.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          controller.text = v ?? '';
          onChanged();
        },
        validator: (v) =>
            field.required && v == null ? context.t('requiredField') : null,
      );
    }
    if (field.input == EditorInput.dateTime) {
      final date = DateTime.tryParse(controller.text);
      return InkWell(
        onTap: () async {
          final initial = date == null
              ? CenterClock.now()
              : CenterClock.local(date);
          final day = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100, 12, 31),
          );
          if (day == null || !context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initial),
          );
          if (time == null) return;
          controller.text = CenterClock.at(
            day,
            time.hour,
            time.minute,
          ).toIso8601String();
          onChanged();
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: field.label),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  date == null
                      ? context.t('choose')
                      : '${context.date(date)} · ${context.time(date)}',
                ),
              ),
              if (!field.required && date != null)
                IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: context.t('cancel'),
                )
              else
                const Icon(Icons.calendar_today_outlined, size: 18),
            ],
          ),
        ),
      );
    }
    return NcField(
      label: field.label,
      controller: controller,
      lines: field.input == EditorInput.multiline ? 3 : 1,
      keyboardType: field.input == EditorInput.money
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      validator: (v) {
        if (field.required && (v?.trim().isEmpty ?? true)) {
          return context.t('requiredField');
        }
        if (field.input == EditorInput.money) {
          try {
            Money.parse(v ?? '');
          } catch (_) {
            return context.t('invalidAmount');
          }
        }
        return null;
      },
    );
  }
}
