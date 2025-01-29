import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class RequestHelper {
  String dateTimeFromEpoch(int unixTimestamp, String timezone) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    tz.initializeTimeZones();
    Location timezoneLocation = tz.getLocation(timezone);
    return dateFormat.format(tz.TZDateTime.fromMillisecondsSinceEpoch(
        timezoneLocation, unixTimestamp * 1000));
  }
}
