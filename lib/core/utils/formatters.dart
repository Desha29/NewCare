import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../localization/localization_extensions.dart';
import 'center_clock.dart';

extension AppFormatters on BuildContext {
  String calendarDate(DateTime value) =>
      DateFormat.yMMMd(Localizations.localeOf(this).languageCode).format(value);
  String money(int minor) => NumberFormat.currency(
    locale: Localizations.localeOf(this).languageCode == 'ar' ? 'ar_EG' : 'en',
    symbol: t('currency'),
    decimalDigits: minor % 100 == 0 ? 0 : 2,
  ).format(minor / 100);
  String date(DateTime value) =>
      DateFormat.yMMMd(Localizations.localeOf(this).languageCode)
          .format(CenterClock.local(value));
  String shortDate(DateTime value) =>
      DateFormat.yMd(Localizations.localeOf(this).languageCode)
          .format(CenterClock.local(value));
  String time(DateTime value) =>
      DateFormat.jm(Localizations.localeOf(this).languageCode)
          .format(CenterClock.local(value));
}
