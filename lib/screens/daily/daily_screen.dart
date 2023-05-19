import 'dart:developer';

import 'package:calendar/components/date_slider.dart';
import 'package:calendar/components/drawer/drawer.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/daily/app_bar.dart';
import 'package:calendar/screens/daily/caregiver_view.dart';
import 'package:calendar/screens/daily/dependent_view.dart';
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

  @override
  void initState() {
    // RealmManager realmManager =
    //     Provider.of<RealmManager>(context, listen: false);
    // calendarDataSource = EventCalendarDataSource(
    //     realmManager.realm!, events.toList(), selectedDate, Theme.of(context));
    super.initState();
  }

  setSelectedDate(date) {
    setState(() {
      selectedDate = date;
    });
    calendarController.displayDate = date;
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
      final idsToFilter = [];
      final sorted = newEvents
          .map((e) {
            final event = EventModel(realmManager.realm!, e as Event);
            if (!event.isRecurring) return event;

            event.originalRecurrenceStartDateTime = event.startDateTime;

            final newStart = getAdjustedRecurringStartDate(event, selectedDate);
            if (newStart != null) {
              event.startDateTime = newStart;
            } else {
              idsToFilter.add(event.id);
            }

            return event;
          })
          .where((event) => !idsToFilter.contains(event.id))
          .toList();

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

    DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
            .toUtc();
    DateTime endDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
            .add(const Duration(days: 1))
            .toUtc();
    String startDateStr = DateFormat('y-M-d@HH:mm:ss:0').format(startDate);
    String endDateStr = DateFormat('y-M-d@HH:mm:ss:0').format(endDate);

    var eventsQueryName = 'listEvents-$startDateStr-${appState.activeTeam!.id}';
    var eventsQueryString =
        '(startDateTime BETWEEN {$startDateStr,$endDateStr} OR (startDateTime <= $startDateStr AND isRecurring == true)) AND isDeleted == false AND teamId == \$0';
    var eventsQueryArgs = [appState.activeTeam!.id];

    final eventIds = events.map((e) => 'oid(${e.id})').toList();
    final format = DateFormat('y-M-d@HH:mm:ss:0').format;
    var completionRecordsQueryName =
        'get-completion-records-${appState.activeTeam!.id}-$startDate-${eventIds.toString()}';
    var completionRecordsQueryString =
        '(recurringInstanceDateTime BETWEEN {${format(startDate)},${format(endDate)}} OR (recurringInstanceDateTime = nil && eventId IN {${eventIds.join((','))}})) AND isDeleted == false';

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
              DateSlider(selectedDate, setSelectedDate),
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
                        child: Builder(builder: ((context) {
                          if (appState.teamUserType == 'caregiver' &&
                              selectedView == 'manage') {
                            return CaregiverView(
                                calendarController: calendarController,
                                calendarDataSource: calendarDataSource,
                                events: events,
                                completionRecords: completionRecords,
                                activeDate: selectedDate);
                          } else {
                            return Expanded(
                                child: DependentView(
                                    events: events,
                                    completionRecords: completionRecords,
                                    activeDate: selectedDate));
                          }
                        })));
                  }))),
            ],
          );
        })));
  }
}
