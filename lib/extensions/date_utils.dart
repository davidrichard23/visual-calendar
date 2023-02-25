import 'package:jiffy/jiffy.dart';

extension DateUtils on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  int daysBetween(DateTime date) {
    var from = Jiffy([year, month, day]);
    var to = Jiffy([date.year, date.month, date.day]);
    return from.diff(to, Units.DAY) as int;
  }

  int weeksBetween(DateTime date) {
    var from = Jiffy([year, month, day]);
    var to = Jiffy([date.year, date.month, date.day]);
    return from.diff(to, Units.WEEK) as int;
  }

  int monthsBetween(DateTime date) {
    var from = Jiffy([year, month, day]);
    var to = Jiffy([date.year, date.month, date.day]);
    return from.diff(to, Units.MONTH) as int;
  }

  int yearsBetween(DateTime date) {
    var from = Jiffy([year, month, day]);
    var to = Jiffy([date.year, date.month, date.day]);
    return from.diff(to, Units.YEAR) as int;
  }

  DateTime get nearestFiveMins {
    return DateTime(
        year,
        month,
        day,
        hour,
        [
          0,
          5,
          10,
          15,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          60
        ][(minute / 5).round()]);
  }

  DateTime get nearestFifteenMins {
    return DateTime(
        year, month, day, hour, [0, 15, 30, 45, 60][(minute / 15).round()]);
  }
}
