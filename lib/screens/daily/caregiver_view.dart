import 'dart:async';
import 'dart:developer';

import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/daily/calendar_widgets/day_view_appointment.dart';
import 'package:calendar/screens/daily/calendar_widgets/month_view_appointment.dart';
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
  final Function(CalendarView) setCalendarViewMode;
  final Function(DateTime) setActiveDate;
  final DateTime activeDate;

  const CaregiverView(
      {Key? key,
      required this.calendarController,
      this.calendarDataSource,
      required this.events,
      required this.completionRecords,
      required this.setCalendarViewMode,
      required this.setActiveDate,
      required this.activeDate})
      : super(key: key);

  @override
  State<CaregiverView> createState() => _CaregiverViewState();
}

class _CaregiverViewState extends State<CaregiverView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var monthRenderTracking = {};

    void onEventSelectionChange(CalendarTapDetails details) {
      if (widget.calendarController.view == CalendarView.month) {
        if (details.date != null) widget.setActiveDate(details.date!);
        widget.setCalendarViewMode(CalendarView.day);
        widget.calendarController.selectedDate = null;
        return;
      }

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

    void onViewChanged(ViewChangedDetails details) {
      Timer(const Duration(milliseconds: 100), () {
        widget.setActiveDate(details.visibleDates[0]);
      });
    }

    return Expanded(
        child: SafeArea(
            bottom: true,
            child: Row(children: [
              Expanded(
                  flex: 6,
                  child: SfCalendarTheme(
                      data: SfCalendarThemeData(
                          selectionBorderColor: theme.cardColor),
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
                        onViewChanged: onViewChanged,
                        onTap: onEventSelectionChange,
                        onDragEnd: onDragEnd,
                        todayHighlightColor: theme.primaryColor,
                        timeSlotViewSettings:
                            const TimeSlotViewSettings(timeIntervalHeight: -1),
                        monthViewSettings: const MonthViewSettings(
                            showTrailingAndLeadingDates: false,
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                        monthCellBuilder: (BuildContext buildContext,
                            MonthCellDetails details) {
                          return Container(
                              clipBehavior: Clip.hardEdge,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey[300]!, width: 0.5)),
                              child: SingleChildScrollView(
                                  child: Column(children: [
                                Text(
                                  details.date.day.toString(),
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                ...details.appointments.map((appointment) =>
                                    MonthViewAppointment(
                                        completionRecords:
                                            widget.completionRecords,
                                        appointment: appointment))
                              ])));
                        },
                        appointmentBuilder: (context, details) {
                          if (widget.calendarController.view ==
                              CalendarView.day) {
                            return DayViewAppointment(
                                completionRecords: widget.completionRecords,
                                appointments: details.appointments);
                          } else {
                            return Container();
                            final day =
                                details.appointments.first.startDateTime.day;
                            // if (!monthRenderTracking.containsKey(day)) {
                            //   monthRenderTracking[details
                            //       .appointments.first.startDateTime.day] = 0;
                            //   return Container();
                            // }
                            // if (monthRenderTracking[day] > 5) {
                            //   return Container();
                            // }

                            // monthRenderTracking[
                            //     details.appointments.first.startDateTime.day]++;
                            print(details.appointments.first.startDateTime.day);
                            print('length: ' +
                                details.appointments.length.toString());
                            return MonthViewAppointment(
                                completionRecords: widget.completionRecords,
                                appointment: details.appointments.first);
                          }
                        },
                      ))),
              if (!ResponsiveLayoutHelper.isMobile(context))
                Expanded(
                    flex: 4,
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: Colors.black.withOpacity(0.2),
                                    width: 1))),
                        child: DependentView(
                            events: widget.events,
                            completionRecords: widget.completionRecords,
                            activeDate: widget.activeDate)))
            ])));
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
