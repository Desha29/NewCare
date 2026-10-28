import 'dart:convert';
import 'dart:typed_data';

abstract final class CsvExporter {
  static String cell(String value) {
    final safe = RegExp(r'^[\s]*[=+\-@]').hasMatch(value) ? "'$value" : value;
    return '"${safe.replaceAll('"', '""')}"';
  }

  static Uint8List encode(List<List<String>> rows) => Uint8List.fromList(
    utf8.encode('\uFEFF${rows.map((r) => r.map(cell).join(',')).join('\r\n')}'),
  );
}
