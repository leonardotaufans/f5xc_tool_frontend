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

  String getInitialsFromName(String? fullName) {
    if (fullName == null) {
      return "";
    }
    String localName = fullName ?? "Not Available";
    var name = localName.split(' ');
    String initials = "";
    initials += name[0].substring(0, 0);
    if (name.length > 1) {
      initials += name[name.length-1].substring(0, 0);
    }
    print(initials);
    return initials;
  }
}
