import 'package:timezone/timezone.dart' as tz;

/// Helper class for timezone-aware date and time operations
class TimezoneHelper {
  /// Get current time in local timezone
  static tz.TZDateTime now() {
    return tz.TZDateTime.now(tz.local);
  }

  /// Convert a DateTime to local timezone
  static tz.TZDateTime toLocal(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Convert UTC DateTime to local timezone
  static tz.TZDateTime fromUtc(DateTime utcDateTime) {
    return tz.TZDateTime.from(utcDateTime.toUtc(), tz.local);
  }

  /// Convert local time to UTC
  static DateTime toUtc(DateTime localDateTime) {
    final tzDateTime = tz.TZDateTime.from(localDateTime, tz.local);
    return tzDateTime.toUtc();
  }

  /// Parse a date string with timezone consideration
  static tz.TZDateTime parse(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Get timezone name
  static String getTimezoneName() {
    return tz.local.name;
  }

  /// Get current timezone offset in hours
  static int getTimezoneOffsetHours() {
    return DateTime.now().timeZoneOffset.inHours;
  }

  /// Format DateTime with timezone info
  static String formatWithTimezone(DateTime dateTime) {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
    final offset = tzDateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${tzDateTime.toString()} (UTC$sign$hours:$minutes)';
  }

  /// Create a TZDateTime for a specific date and time in local timezone
  static tz.TZDateTime createLocalDateTime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    return tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Check if a DateTime is today in local timezone
  static bool isToday(DateTime dateTime) {
    final now = TimezoneHelper.now();
    final localDate = tz.TZDateTime.from(dateTime, tz.local);
    return now.year == localDate.year &&
           now.month == localDate.month &&
           now.day == localDate.day;
  }

  /// Get start of day in local timezone
  static tz.TZDateTime startOfDay(DateTime dateTime) {
    final localDate = tz.TZDateTime.from(dateTime, tz.local);
    return tz.TZDateTime(
      tz.local,
      localDate.year,
      localDate.month,
      localDate.day,
    );
  }

  /// Get end of day in local timezone
  static tz.TZDateTime endOfDay(DateTime dateTime) {
    final localDate = tz.TZDateTime.from(dateTime, tz.local);
    return tz.TZDateTime(
      tz.local,
      localDate.year,
      localDate.month,
      localDate.day,
      23,
      59,
      59,
      999,
    );
  }
}
