import 'package:timezone/timezone.dart' as tz;
import 'center_clock.dart';

class OperationalDay {
  const OperationalDay({required this.start, required this.end});

  final DateTime start; // 08:00:00 Africa/Cairo
  final DateTime end;   // 08:00:00 Africa/Cairo next day

  factory OperationalDay.containing(DateTime dateTime) {
    final local = CenterClock.local(dateTime);
    final tz.Location loc = CenterClock.location;
    // If local.hour < 8, this belongs to the day starting yesterday at 08:00
    final tz.TZDateTime dayBase = local.hour < 8
        ? tz.TZDateTime(loc, local.year, local.month, local.day - 1, 8, 0)
        : tz.TZDateTime(loc, local.year, local.month, local.day, 8, 0);
    final tz.TZDateTime dayEnd = tz.TZDateTime(loc, dayBase.year, dayBase.month, dayBase.day + 1, 8, 0);
    return OperationalDay(start: dayBase, end: dayEnd);
  }

  factory OperationalDay.today() => OperationalDay.containing(CenterClock.now());

  bool contains(DateTime dateTime) {
    final local = CenterClock.local(dateTime);
    return !local.isBefore(start) && local.isBefore(end);
  }

  OperationalDay get previous {
    final tz.Location loc = CenterClock.location;
    final prevStart = tz.TZDateTime(loc, start.year, start.month, start.day - 1, 8, 0);
    return OperationalDay(start: prevStart, end: start);
  }

  OperationalDay get next {
    final tz.Location loc = CenterClock.location;
    final nextEnd = tz.TZDateTime(loc, end.year, end.month, end.day + 1, 8, 0);
    return OperationalDay(start: end, end: nextEnd);
  }

  String get id =>
      '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationalDay &&
          runtimeType == other.runtimeType &&
          start.isAtSameMomentAs(other.start) &&
          end.isAtSameMomentAs(other.end);

  @override
  int get hashCode => Object.hash(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
}

