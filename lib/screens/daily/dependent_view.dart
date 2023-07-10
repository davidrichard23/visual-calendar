import 'dart:developer';

import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:calendar/models/completion_record_model.dart';
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
  final List<CompletionRecordModel> completionRecords;
  final DateTime activeDate;

  const DependentView(
      {Key? key,
      required this.events,
      required this.completionRecords,
      required this.activeDate})
      : super(key: key);

  @override
  State<DependentView> createState() => _DependentViewState();
}

class _DependentViewState extends State<DependentView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startDateTime = widget.activeDate.toLocal();
    final startDate =
        DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
    final endDate = DateTime(
        startDateTime.year, startDateTime.month, startDateTime.day + 1);

    final filteredEvents = widget.events
        .where((event) =>
            event.startDateTime.toLocal().isAfter(startDate) &&
            event.startDateTime.toLocal().isBefore(endDate))
        .toList();

    return Container(
        color: theme.backgroundColor,
        child: ListView.builder(
            itemCount: filteredEvents.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return MaxWidth(
                    maxWidth: maxWidth,
                    child: Column(children: [
                      DateHeader(date: widget.activeDate),
                      if (!filteredEvents.isNotEmpty)
                        const PrimaryCard(
                            child:
                                H1('You Have No Events Today!', center: true)),
                    ]));
              }

              index -= 1;

              final event = filteredEvents[index];
              final isRecurring = event.isRecurring;
              bool isCompleted;
              if (isRecurring) {
                final startDate = DateTime(event.startDateTime.year,
                    event.startDateTime.month, event.startDateTime.day);
                final endDate = DateTime(event.startDateTime.year,
                    event.startDateTime.month, event.startDateTime.day + 1);

                isCompleted = widget.completionRecords.any((r) =>
                    r.eventId == event.id &&
                    r.item.createdAt!.isAfter(startDate) &&
                    r.item.createdAt!.isBefore(endDate));
              } else {
                isCompleted =
                    widget.completionRecords.any((r) => r.eventId == event.id);
              }
              return MaxWidth(
                  maxWidth: maxWidth,
                  child: EventRow(
                      event: event,
                      events: filteredEvents,
                      isCompleted: isCompleted,
                      activeDateTime: widget.activeDate));
            }));
  }
}
