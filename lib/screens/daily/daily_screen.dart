import 'dart:developer';

import 'package:calendar/components/date_slider.dart';
import 'package:calendar/components/drawer/drawer.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/models/recurrence_override_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/daily/app_bar.dart';
import 'package:calendar/screens/daily/caregiver_view.dart';
import 'package:calendar/screens/daily/dependent_view.dart';
import 'package:calendar/screens/daily/month_header.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_adjusted_recurring_start_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final CalendarController calendarController = CalendarController();
  EventCalendarDataSource? calendarDataSource;
  String selectedView = 'manage';
  DateTime selectedDate = DateTime.now();
  List<EventModel> events = [];
  List<CompletionRecordModel> completionRecords = [];
  bool showingMonthView = false;

  @override
  void initState() {
    // RealmManager realmManager =
    //     Provider.of<RealmManager>(context, listen: false);
    // calendarDataSource = EventCalendarDataSource(
    //     realmManager.realm!, events.toList(), selectedDate, Theme.of(context));
    super.initState();
  }

  setActiveDate(date) {
    setState(() {
      selectedDate = date;
    });
    calendarController.displayDate = date;
  }

  setCalendarViewMode(CalendarView view) {
    calendarController.view = view;
    setState(() {
      showingMonthView = calendarController.view == CalendarView.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);

    // find a better way?
    if (appState.activeTeam == null || realmManager.realm == null) {
      return Container();
    }

    void onNewEvents<T extends RealmObject>(RealmResults<T> newEvents) {
      final List<EventModel> sorted = [];

      for (var e in newEvents) {
        final event = EventModel(realmManager.realm!, e as Event);
        event.originalRecurrenceStartDateTime = event.startDateTime;

        if (!event.isRecurring) {
          sorted.add(event);
          continue;
        }

        final daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

        for (var i = 1; i <= daysInMonth; i++) {
          final eventDup = EventModel(realmManager.realm!, e);
          eventDup.originalRecurrenceStartDateTime = event.startDateTime;
          final newSelectedDate =
              DateTime(selectedDate.year, selectedDate.month, i);
          final newStart =
              getAdjustedRecurringStartDate(event, newSelectedDate);
          if (newStart != null) {
            eventDup.startDateTime = newStart;
            sorted.add(eventDup);
          }
        }
      }

      sorted.sort((a, b) {
        return a.startDateTime.compareTo(b.startDateTime);
      });

      setState(() {
        events = sorted;
        calendarDataSource = EventCalendarDataSource(realmManager.realm!,
            sorted.toList(), selectedDate, Theme.of(context));
      });
    }

    void onNewCompletionRecords<T extends RealmObject>(
        RealmResults<T> newCompletionRecords) {
      setState(() {
        completionRecords = newCompletionRecords
            .map((r) => CompletionRecordModel(
                realmManager.realm!, r as CompletionRecord))
            .toList();
      });
    }

    void onNewRecurrenceOverrides<T extends RealmObject>(
        RealmResults<T> newRecurrenceOverrides) {
      final recurrenceOverrides = newRecurrenceOverrides
          .map((r) => RecurrenceOverrideModel(
              realmManager.realm!, r as RecurrenceOverride))
          .toList();

      List<EventModel> newAppointments =
          calendarDataSource?.appointments?.where((event) {
        return recurrenceOverrides.every((overrride) {
          final res = overrride.eventId != event.id ||
              !overrride.recurringInstanceDateTime
                  .isAtSameMomentAs(event.startDateTime);
          return res;
        });
      }).toList() as List<EventModel>;

      setState(() {
        calendarDataSource = EventCalendarDataSource(realmManager.realm!,
            newAppointments, selectedDate, Theme.of(context));
      });
    }

    DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, 1).toUtc();
    DateTime endDate =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).toUtc();
    String startDateStr = DateFormat('y-M-d@HH:mm:ss:0').format(startDate);
    String endDateStr = DateFormat('y-M-d@HH:mm:ss:0').format(endDate);

    final eventsQueryName =
        'listEvents-$startDateStr-${appState.activeTeam!.id}';
    final eventsQueryString =
        '(startDateTime BETWEEN {$startDateStr,$endDateStr} OR (startDateTime <= $startDateStr AND isRecurring == true)) AND isDeleted == false AND teamId == \$0';
    final eventsQueryArgs = [appState.activeTeam!.id];

    final eventIds = events.map((e) => 'oid(${e.id})').toList();
    final format = DateFormat('y-M-d@HH:mm:ss:0').format;
    final completionRecordsQueryName =
        'get-completion-records-${appState.activeTeam!.id}-$startDate-${eventIds.toString()}';
    final completionRecordsQueryString =
        '(recurringInstanceDateTime BETWEEN {${format(startDate)},${format(endDate)}} OR (recurringInstanceDateTime = nil && eventId IN {${eventIds.join((','))}})) AND isDeleted == false AND isDeleted == false AND teamId == \$0';
    final completionRecordsQueryArgs = [appState.activeTeam!.id];

    final recurrenceOverrideQueryName =
        'get-recurrence-overrides-${appState.activeTeam!.id}-$startDate-${eventIds.toString()}';
    final recurrenceOverrideQueryString =
        'recurringInstanceDateTime BETWEEN {${format(startDate)},${format(endDate)}} AND isDeleted == false AND isDeleted == false AND teamId == \$0';
    final recurrenceOverrideQueryArgs = [appState.activeTeam!.id];

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: DailyAppBar(
          selectedDateTime: selectedDate,
          changeViewType: (e) => setState(() => selectedView = e),
        ),
        drawer: appState.teamUserType != 'dependent'
            ? const DrawerComponent()
            : null,
        body: Builder(builder: ((context) {
          return Column(
            children: [
              MonthHeader(
                  date: selectedDate,
                  setCalendarViewMode: setCalendarViewMode,
                  setActiveDate: setActiveDate,
                  calendarViewMode: calendarController.view,
                  selectedView: selectedView),
              // if (!showingMonthView) DateSlider(selectedDate, setActiveDate),
              // events
              RealmQueryBuilder<Event>(
                  onUpdate: onNewEvents,
                  queryName: eventsQueryName,
                  queryType: QueryType.queryString,
                  queryString: eventsQueryString,
                  queryArgs: eventsQueryArgs,
                  child: Builder(builder: ((context) {
                    // completion records
                    return RealmQueryBuilder<CompletionRecord>(
                        onUpdate: onNewCompletionRecords,
                        queryName: completionRecordsQueryName,
                        queryType: QueryType.queryString,
                        queryString: completionRecordsQueryString,
                        queryArgs: completionRecordsQueryArgs,
                        child: Builder(builder: ((context) {
                          // recurrence overrides
                          return RealmQueryBuilder<RecurrenceOverride>(
                              onUpdate: onNewRecurrenceOverrides,
                              queryName: recurrenceOverrideQueryName,
                              queryType: QueryType.queryString,
                              queryString: recurrenceOverrideQueryString,
                              queryArgs: recurrenceOverrideQueryArgs,
                              child: Builder(builder: ((context) {
                                if (appState.teamUserType == 'caregiver' &&
                                    selectedView == 'manage') {
                                  return CaregiverView(
                                      calendarController: calendarController,
                                      calendarDataSource: calendarDataSource,
                                      events: events,
                                      completionRecords: completionRecords,
                                      setCalendarViewMode: setCalendarViewMode,
                                      setActiveDate: setActiveDate,
                                      activeDate: selectedDate);
                                } else {
                                  return Expanded(
                                      child: DependentView(
                                          events: events,
                                          completionRecords: completionRecords,
                                          activeDate: selectedDate));
                                }
                              })));
                        })));
                  }))),
            ],
          );
        })));
  }
}
