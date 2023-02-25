import 'dart:math';

import 'package:calendar/models/event_model.dart';
import 'package:calendar/extensions/date_utils.dart';

DateTime? getAdjustedRecurringStartDate(
    EventModel event, DateTime selectedDate) {
  final origStartDate = event.startDateTime.toLocal();
  final recurrencePattern = event.recurrencePattern!;
  final recurrenceType = recurrencePattern.recurrenceType;
  final interval = recurrencePattern.interval;

  if (selectedDate.startOfDay.isBefore(origStartDate.startOfDay)) {
    return null;
  }

  if (selectedDate.startOfDay
      .isAfter(recurrencePattern.endDateTime.startOfDay)) {
    return null;
  }

  switch (recurrenceType) {
    case 'daily':
      final daysBetween = origStartDate.daysBetween(selectedDate);
      if (daysBetween % interval == 0) {
        final newStartDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, origStartDate.hour, origStartDate.minute);

        return newStartDate;
      }
      return null;
    case 'weekly':
      final weeksBetween = origStartDate.weeksBetween(selectedDate);
      final isCorrectWeekday =
          recurrencePattern.daysOfWeek.contains(selectedDate.weekday);
      if (isCorrectWeekday && weeksBetween % interval == 0) {
        final newStartDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, origStartDate.hour, origStartDate.minute);

        return newStartDate;
      }
      return null;
    case 'monthly':
      final monthsBetween = origStartDate.monthsBetween(selectedDate);
      final isCorrectDayOfMonth =
          recurrencePattern.daysOfMonth.contains(selectedDate.day);
      if (isCorrectDayOfMonth && monthsBetween % interval == 0) {
        final newStartDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, origStartDate.hour, origStartDate.minute);

        return newStartDate;
      }
      return null;
    case 'yearly':
      final yearsBetween = origStartDate.yearsBetween(selectedDate);
      final isCorrectMonth =
          recurrencePattern.monthsOfYear.contains(selectedDate.month);
      final isCorrectDayOfMonth =
          recurrencePattern.daysOfMonth.contains(selectedDate.day);
      if (isCorrectMonth &&
          isCorrectDayOfMonth &&
          yearsBetween % interval == 0) {
        final newStartDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, origStartDate.hour, origStartDate.minute);

        return newStartDate;
      }
      return null;
    default:
      return null;
  }
}
