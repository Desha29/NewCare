import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../localization/localization_extensions.dart';

class NcField extends StatefulWidget {
  const NcField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.lines = 1,
    this.obscure = false,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int lines;
  final bool obscure, enabled;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<NcField> createState() => _NcFieldState();
}

class _NcFieldState extends State<NcField> {
  late bool obscured;

  @override
  void initState() {
    super.initState();
    obscured = widget.obscure;
  }

  @override
  void didUpdateWidget(covariant NcField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      obscured = widget.obscure;
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    enabled: widget.enabled,
    onChanged: widget.onChanged,
    obscureText: obscured,
    maxLines: widget.lines,
    keyboardType: widget.keyboardType,
    inputFormatters: widget.inputFormatters,
    style: widget.keyboardType?.index == TextInputType.number.index
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)
        : null,
    validator: widget.validator,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      suffixIcon: widget.obscure
          ? IconButton(
              tooltip: context.t(obscured ? 'showPassword' : 'hidePassword'),
              onPressed: widget.enabled
                  ? () => setState(() => obscured = !obscured)
                  : null,
              icon: Icon(
                obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            )
          : null,
    ),
    textInputAction: widget.lines > 1
        ? TextInputAction.newline
        : TextInputAction.next,
  );
}

class NcSelect<T> extends StatelessWidget {
  const NcSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    key: ValueKey(value),
    initialValue: value,
    isExpanded: true,
    items: items,
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
    validator: validator,
    decoration: InputDecoration(labelText: label),
  );
}
