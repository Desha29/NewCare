enum EditorInput { text, money, multiline, choice, toggle, dateTime }

class EditorField {
  const EditorField(
    this.key,
    this.label,
    this.initial, {
    this.input = EditorInput.text,
    this.required = true,
    this.choices = const {},
  });
  final String key, label, initial;
  final EditorInput input;
  final bool required;
  final Map<String, String> choices;
}

class RecordEditorSpec {
  const RecordEditorSpec({
    required this.title,
    required this.fields,
    this.requiresReason = true,
  });
  final String title;
  final List<EditorField> fields;
  final bool requiresReason;
}
