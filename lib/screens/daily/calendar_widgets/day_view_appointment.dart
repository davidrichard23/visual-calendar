import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class DayViewAppointment extends StatelessWidget {
  final List<CompletionRecordModel> completionRecords;
  final Iterable<dynamic> appointments;
  const DayViewAppointment(
      {Key? key, required this.completionRecords, required this.appointments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    handleCompletionRevert(CompletionRecordModel completionRecord) async {
      bool? result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Revert completion?'),
            content:
                const Text('Do you want to mark this event as incomplete?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(
                      false); // dismisses only the dialog and returns false
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

    final theme = Theme.of(context);
    final event = appointments.first;
    final isRecurring = event.isRecurring;
    CompletionRecordModel? completionRecord;
    if (isRecurring) {
      final startDateTime = event.startDateTime.toLocal();
      final startDate =
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
      final endDate = DateTime(
          startDateTime.year, startDateTime.month, startDateTime.day + 1);

      completionRecord = completionRecords.firstWhereOrNull((r) =>
          r.eventId == event.id &&
          r.item.createdAt!.toLocal().isAfter(startDate) &&
          r.item.createdAt!.toLocal().isBefore(endDate));
    } else {
      completionRecord =
          completionRecords.firstWhereOrNull((r) => r.eventId == event.id);
    }

    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
              border:
                  Border(left: BorderSide(width: 8, color: theme.primaryColor)),
            ),
            child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (completionRecord != null)
                    GestureDetector(
                        onTap: () => handleCompletionRevert(completionRecord!),
                        child: Padding(
                            padding: const EdgeInsets.only(right: 4, top: 2),
                            child: Center(
                                child: Icon(
                              Icons.check_circle_rounded,
                              color: theme.cardColor,
                              size: 16,
                            )))),
                  // ]),
                  Flexible(
                      child: Paragraph(
                    appointments.first.title,
                    small: true,
                  ))
                ])));
  }
}
