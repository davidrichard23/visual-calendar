import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:calendar/extensions/date_utils.dart';

class CaregiverView extends StatefulWidget {
  final CalendarController calendarController;
  final EventCalendarDataSource? calendarDataSource;

  const CaregiverView(
      {Key? key, required this.calendarController, this.calendarDataSource})
      : super(key: key);

  @override
  State<CaregiverView> createState() => _CaregiverViewState();
}

class _CaregiverViewState extends State<CaregiverView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onEventSelectionChange(CalendarTapDetails details) {
      if (details.appointments == null) {
        widget.calendarController.selectedDate = null;
        Navigator.pushNamed(context, '/create-event',
            arguments: CreateEditScreenArgs(
                initalStartDate: details.date, initalDuration: 60));
        return;
      }

      EventModel event = details.appointments![0] as EventModel;
      Navigator.pushNamed(context, '/create-event',
          arguments: CreateEditScreenArgs(existingEvent: event));
    }

    void onDragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
      if (appointmentDragEndDetails.droppingTime == null) return;
      EventModel event = appointmentDragEndDetails.appointment as EventModel;
      final newTime =
          appointmentDragEndDetails.droppingTime!.nearestFifteenMins;
      final newDateTime = DateTime(
          event.startDateTime.toLocal().year,
          event.startDateTime.toLocal().month,
          event.startDateTime.toLocal().day,
          newTime.hour,
          newTime.minute);
      event.setStartDateTime(newDateTime);
    }

    return Expanded(
        child: SfCalendarTheme(
            data: SfCalendarThemeData(selectionBorderColor: theme.cardColor),
            child: SfCalendar(
              controller: widget.calendarController,
              view: CalendarView.day,
              dataSource: widget.calendarDataSource,
              viewHeaderHeight: 0,
              headerHeight: 0,
              allowAppointmentResize: true,
              allowDragAndDrop: true,
              dragAndDropSettings:
                  const DragAndDropSettings(showTimeIndicator: false),
              viewNavigationMode: ViewNavigationMode.none,
              onTap: onEventSelectionChange,
              onDragEnd: onDragEnd,
              todayHighlightColor: theme.cardColor,
              appointmentBuilder: (context, details) {
                return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ]),
                    child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Paragraph(
                            details.appointments.first.title,
                            small: true,
                          )
                        ]));
              },
            )));
  }
}

class EventCalendarDataSource extends CalendarDataSource<EventModel> {
  late Realm realm;
  DateTime selectedDate;
  ThemeData theme;

  EventCalendarDataSource(
      Realm realm, List<EventModel> source, this.selectedDate, this.theme) {
    realm = realm;
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final EventModel event = appointments![index];
    final startDate = event.startDateTime.toLocal();

    if (!event.isRecurring) return startDate;

    var recurrencePattern = event.recurrencePattern!;
    var recurrenceType = recurrencePattern.recurrenceType;
    var interval = recurrencePattern.interval;

    if (selectedDate.startOfDay.isBefore(startDate.startOfDay)) {
      return startDate;
    }

    if (selectedDate.startOfDay
        .isAfter(recurrencePattern.endDateTime.startOfDay)) {
      return startDate;
    }

    switch (recurrenceType) {
      case 'daily':
        final daysBetween = startDate.daysBetween(selectedDate);
        if (daysBetween % interval == 0) {
          final newStartDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, startDate.hour, startDate.minute);

          return newStartDate;
        }
        return startDate;
      case 'weekly':
        final weeksBetween = startDate.weeksBetween(selectedDate);
        final isCorrectWeekday =
            recurrencePattern.daysOfWeek.contains(selectedDate.weekday);
        if (isCorrectWeekday && weeksBetween % interval == 0) {
          final newStartDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, startDate.hour, startDate.minute);

          return newStartDate;
        }
        return startDate;
      case 'monthly':
        final monthsBetween = startDate.monthsBetween(selectedDate);
        final isCorrectDayOfMonth =
            recurrencePattern.daysOfMonth.contains(selectedDate.day);
        if (isCorrectDayOfMonth && monthsBetween % interval == 0) {
          final newStartDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, startDate.hour, startDate.minute);

          return newStartDate;
        }
        return startDate;
      case 'yearly':
        final yearsBetween = startDate.yearsBetween(selectedDate);
        final isCorrectMonth =
            recurrencePattern.monthsOfYear.contains(selectedDate.month);
        final isCorrectDayOfMonth =
            recurrencePattern.daysOfMonth.contains(selectedDate.day);
        if (isCorrectMonth &&
            isCorrectDayOfMonth &&
            yearsBetween % interval == 0) {
          final newStartDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, startDate.hour, startDate.minute);

          return newStartDate;
        }
        return startDate;
      default:
        return startDate;
    }
  }

  @override
  DateTime getEndTime(int index) {
    var start = getStartTime(index);
    return start
        .toLocal()
        .add(Duration(minutes: appointments![index].duration));
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return theme.primaryColor;
    // return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  EventModel convertAppointmentToObject(
      EventModel customData, Appointment appointment) {
    return customData;
  }
}
