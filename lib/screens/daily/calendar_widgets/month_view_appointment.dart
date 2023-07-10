import 'dart:developer';

import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MonthViewAppointment extends StatelessWidget {
  final List<CompletionRecordModel> completionRecords;
  final dynamic appointment;
  const MonthViewAppointment(
      {Key? key, required this.completionRecords, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final completionRecord = completionRecords
    //     .firstWhereOrNull((r) => r.eventId == appointments.first.id);
    // final isCompleted = completionRecord != null;
    // log(appointment.title);
    return Container(
        clipBehavior: Clip.hardEdge,
        // margin: EdgeInsets.only(bottom: 2),
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
            child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if (isCompleted)
                  //   Padding(
                  //       padding: const EdgeInsets.only(right: 4, top: 2),
                  //       child: Center(
                  //           child: Icon(
                  //         Icons.check_circle_rounded,
                  //         color: theme.cardColor,
                  //         size: 16,
                  //       ))),
                  // ]),
                  Flexible(
                      child: Text(
                    appointment.title,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ))
                ])));
  }
}
