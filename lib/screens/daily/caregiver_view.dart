import 'dart:developer';

import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/daily/dependent_view.dart';
import 'package:calendar/util/responsive_layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:collection/collection.dart';

class CaregiverView extends StatefulWidget {
  final CalendarController calendarController;
  final EventCalendarDataSource? calendarDataSource;
  final List<EventModel> events;
  final List<CompletionRecordModel> completionRecords;
  final DateTime activeDate;

  const CaregiverView(
      {Key? key,
      required this.calendarController,
      this.calendarDataSource,
      required this.events,
      required this.completionRecords,
      required this.activeDate})
      : super(key: key);

  @override
  State<CaregiverView> createState() => _CaregiverViewState();
}

class _CaregiverViewState extends State<CaregiverView> {
  handleCompletionRevert(CompletionRecordModel completionRecord) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Revert completion?'),
          content: const Text('Do you want to mark this event as incomplete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(false); // dismisses only the dialog and returns false
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(true); // dismisses only the dialog and returns true
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      completionRecord.delete();
    }
  }

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
      final completionRecord = widget.completionRecords
          .firstWhereOrNull((r) => r.eventId == event.id);
      Navigator.pushNamed(context, '/create-event',
          arguments: CreateEditScreenArgs(
              existingEvent: event, completionRecord: completionRecord));
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
                timeSlotViewSettings:
                    const TimeSlotViewSettings(timeIntervalHeight: -1),
                appointmentBuilder: (context, details) {
                  final completionRecord = widget.completionRecords
                      .firstWhereOrNull(
                          (r) => r.eventId == details.appointments.first.id);
                  final isCompleted = completionRecord != null;

                  return Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    width: 8, color: theme.primaryColor)),
                          ),
                          child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isCompleted)
                                  GestureDetector(
                                      onTap: () => handleCompletionRevert(
                                          completionRecord),
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 4, top: 2),
                                          child: Center(
                                              child: Icon(
                                            Icons.check_circle_rounded,
                                            color: theme.cardColor,
                                            size: 16,
                                          )))),
                                // ]),
                                Flexible(
                                    child: Paragraph(
                                  details.appointments.first.title,
                                  small: true,
                                ))
                              ])));
                },
              ))),
      if (!ResponsiveLayoutHelper.isMobile(context))
        Expanded(
            flex: 4,
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            color: Colors.black.withOpacity(0.2), width: 1))),
                child: DependentView(
                    events: widget.events,
                    completionRecords: widget.completionRecords,
                    activeDate: widget.activeDate)))
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
