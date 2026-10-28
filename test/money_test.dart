import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/utils/money.dart';

void main() {
  test('parses Arabic and English money without floating point loss', () {
    expect(Money.parse('١٢٣٫٤٥'), 12345);
    expect(Money.parse('123.45'), 12345);
    expect(Money.parse('0.10'), 10);
    expect(Money.parse('١٬٢٣٤٫٥٠'), 123450);
  });
  test('rejects negative, malformed and excessive decimal inputs', () {
    for (final input in ['-1', '1.234', 'NaN', '1,25', '']) {
      expect(() => Money.parse(input), throwsFormatException);
    }
  });
  test('drawer includes only cash payments and signed cash movements', () {
    expect(
      Money.drawerBalance(
        opening: 20000,
        cashPayments: [25000],
        movements: [-5000, -3000, 1000],
      ),
      38000,
    );
  });
}
