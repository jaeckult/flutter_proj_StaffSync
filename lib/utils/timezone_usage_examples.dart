/// TIMEZONE USAGE EXAMPLES
/// 
/// This file contains examples of how to use the TimezoneHelper throughout your app
/// You can delete this file after reviewing the examples

import 'package:staffsync/utils/timezone_helper.dart';

void timezoneExamples() {
  // Example 1: Get current time in your local timezone
  final now = TimezoneHelper.now();
  print('Current local time: $now');

  // Example 2: Convert a DateTime to local timezone
  final someDate = DateTime.parse('2024-10-15 14:30:00');
  final localDate = TimezoneHelper.toLocal(someDate);
  print('Converted to local: $localDate');

  // Example 3: Convert UTC to local timezone (useful for API responses)
  final utcDate = DateTime.parse('2024-10-15 11:30:00Z');
  final localFromUtc = TimezoneHelper.fromUtc(utcDate);
  print('UTC to local: $localFromUtc');

  // Example 4: Check if a date is today
  final isToday = TimezoneHelper.isToday(DateTime.now());
  print('Is today: $isToday');

  // Example 5: Get start and end of day
  final startOfDay = TimezoneHelper.startOfDay(DateTime.now());
  final endOfDay = TimezoneHelper.endOfDay(DateTime.now());
  print('Start of day: $startOfDay');
  print('End of day: $endOfDay');

  // Example 6: Get timezone info
  print('Timezone: ${TimezoneHelper.getTimezoneName()}');
  print('Offset: UTC+${TimezoneHelper.getTimezoneOffsetHours()}');

  // Example 7: Create a specific date in local timezone
  final specificDate = TimezoneHelper.createLocalDateTime(2024, 10, 15, 9, 0, 0);
  print('Specific local date: $specificDate');
}

/// PRACTICAL USAGE IN YOUR APP:

// In attendance.notifier.dart - when creating check-in time:
// Instead of: DateTime.now()
// Use: TimezoneHelper.now()

// When comparing dates (e.g., checking if attendance is today):
// Instead of: 
//   DateTime.now().year == attendance.date.year && ...
// Use:
//   TimezoneHelper.isToday(attendance.date)

// When receiving datetime from backend API:
// If backend sends UTC:
//   final localTime = TimezoneHelper.fromUtc(apiDateTime);
// If backend sends in specific timezone:
//   final localTime = TimezoneHelper.toLocal(apiDateTime);

// When sending datetime to backend API:
// Convert to UTC first:
//   final utcTime = TimezoneHelper.toUtc(localDateTime);
