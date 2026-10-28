abstract final class Money {
  static int parse(String input) {
    var value = input.trim();
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
    }
    value = value.replaceAll('٫', '.').replaceAll('٬', '');
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      throw const FormatException('invalidAmount');
    }
    final parts = value.split('.');
    final minor =
        int.parse(parts.first) * 100 +
        (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
    if (minor > 10000000000) throw const FormatException('invalidAmount');
    return minor;
  }

  static int drawerBalance({
    required int opening,
    required Iterable<int> cashPayments,
    required Iterable<int> movements,
  }) =>
      opening +
      cashPayments.fold<int>(0, (a, b) => a + b) +
      movements.fold<int>(0, (a, b) => a + b);
}
