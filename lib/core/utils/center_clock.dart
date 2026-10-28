import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

abstract final class CenterClock {
  static bool _ready = false;
  static tz.Location get location {
    if (!_ready) {
      data.initializeTimeZones();
      _ready = true;
    }
    return tz.getLocation('Africa/Cairo');
  }

  static DateTime now() => tz.TZDateTime.now(location);
  static DateTime at(DateTime day, int hour, int minute) =>
      tz.TZDateTime(location, day.year, day.month, day.day, hour, minute);
  static DateTime dayStart(DateTime date) =>
      tz.TZDateTime(location, date.year, date.month, date.day);
  static DateTime dayAfter(DateTime date) =>
      tz.TZDateTime(location, date.year, date.month, date.day + 1);
  static DateTime local(DateTime value) => tz.TZDateTime.from(value, location);
}
