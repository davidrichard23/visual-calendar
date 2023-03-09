import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/screens/daily/dependent_view.dart';
import 'package:calendar/util/get_adjusted_recurring_start_date.dart';
import 'package:calendar/util/responsive_layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:calendar/extensions/date_utils.dart';

class CaregiverView extends StatefulWidget {
  final CalendarController calendarController;
  final EventCalendarDataSource? calendarDataSource;
  final List<EventModel> events;
  final DateTime activeDate;

  const CaregiverView(
      {Key? key,
      required this.calendarController,
      this.calendarDataSource,
      required this.events,
      required this.activeDate})
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
        child: Row(children: [
      Expanded(
          flex: 6,
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
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
                            Flexible(
                                child: Paragraph(
                              details.appointments.first.title,
                              small: true,
                            ))
                          ]));
                },
              ))),
      if (!ResponsiveLayoutHelper.isMobile(context))
        Expanded(
            flex: 4,
            child: DependentView(
                events: widget.events, activeDate: widget.activeDate))
    ]));
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

    return startDate;
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
