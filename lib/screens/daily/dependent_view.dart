import 'dart:developer';

import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/daily/date_header.dart';
import 'package:calendar/screens/daily/event_row.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class DependentView extends StatefulWidget {
  final List<EventModel> events;
  final DateTime activeDate;

  const DependentView(
      {Key? key, required this.events, required this.activeDate})
      : super(key: key);

  @override
  State<DependentView> createState() => _DependentViewState();
}

class _DependentViewState extends State<DependentView> {
  var didChooseInitialRoute = false;
  List<CompletionRecord> completionRecords = [];

  void onUpdate<T extends RealmObject>(RealmResults<T> newCompletionRecords) {
    setState(() {
      completionRecords =
          newCompletionRecords.map((r) => r as CompletionRecord).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    final eventIds = widget.events.map((e) => 'oid(${e.id})').toList();
    final format = DateFormat('y-M-d@HH:mm:ss:0').format;
    final start = widget.activeDate.startOfDay;
    final end =
        start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    var queryName =
        'get-completion-records-${appState.activeTeam!.id}-$start-${eventIds.toString()}';

    final queryString =
        'recurringInstanceDateTime BETWEEN {${format(start)},${format(end)}} OR (recurringInstanceDateTime = nil && eventId IN {${eventIds.join((','))}})';

    return RealmQueryBuilder<CompletionRecord>(
        onUpdate: onUpdate,
        queryName: queryName,
        queryString: queryString,
        queryType: QueryType.queryString,
        child: Builder(builder: ((context) {
          return Container(
              color: theme.backgroundColor,
              child: ListView.builder(
                  itemCount: widget.events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return MaxWidth(
                          maxWidth: maxWidth,
                          child: Column(children: [
                            DateHeader(date: widget.activeDate),
                            if (!widget.events.isNotEmpty)
                              const PrimaryCard(
                                  child: H1('You Have No Events Today!',
                                      center: true)),
                          ]));
                    }

                    index -= 1;

                    var event = widget.events[index];
                    final isCompleted =
                        completionRecords.any((r) => r.eventId == event.id);
                    return MaxWidth(
                        maxWidth: maxWidth,
                        child: EventRow(
                            event: event,
                            events: widget.events,
                            isCompleted: isCompleted,
                            activeDateTime: widget.activeDate));
                  }));
        })));
  }
}
