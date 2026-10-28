import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
abstract final class CenterClock{
  static bool _ready=false;
  static tz.Location get location{if(!_ready){data.initializeTimeZones();_ready=true;}return tz.getLocation('Africa/Cairo');}
  static DateTime now()=>tz.TZDateTime.now(location);
  static DateTime local(DateTime value)=>tz.TZDateTime.from(value,location);
}

