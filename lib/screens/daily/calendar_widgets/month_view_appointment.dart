import 'dart:developer';

import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MonthViewAppointment extends StatelessWidget {
  final List<CompletionRecordModel> completionRecords;
  final dynamic appointment;

  const MonthViewAppointment(
      {super.key, required this.completionRecords, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final completionRecord = completionRecords
    //     .firstWhereOrNull((r) => r.eventId == appointments.first.id);
    // final isCompleted = completionRecord != null;
    // log(appointment.title);
    print(appointment.title);
    return Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
            padding: const EdgeInsets.only(left: 3, right: 2),
            decoration: BoxDecoration(
              border:
                  Border(left: BorderSide(width: 4, color: theme.primaryColor)),
            ),
            child: Row(children: [
              Flexible(
                  child: Text(
                appointment.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ))
            ])));
  }
}
