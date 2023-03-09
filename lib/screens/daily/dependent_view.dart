import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/screens/daily/date_header.dart';
import 'package:calendar/screens/daily/event_row.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
        child: Container(
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
                  // nextCalItemIndex
                  return MaxWidth(
                      maxWidth: maxWidth,
                      child: EventRow(
                          event: event,
                          events: widget.events,
                          nextCalItemIndex: 0));
                })));
  }
}
