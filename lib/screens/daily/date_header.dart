import 'package:calendar/components/text/h1.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:calendar/extensions/int_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    var isToday = date.isToday;
    var isTomorrow = date.isTomorrow;
    var isYesterday = date.isYesterday;

    String dateHeaderString = isToday
        ? 'TODAY'
        : isTomorrow
            ? 'TOMORROW'
            : isYesterday
                ? 'YESTERDAY'
                : DateFormat('EEEE MMMM ').format(date) +
                    date.day.toOrdinalString();

    return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Icon(Icons.today_rounded,
              size: 45.0, color: Color.fromRGBO(0, 53, 60, 1)),
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: H1(dateHeaderString,
                large: true, color: const Color.fromRGBO(0, 53, 60, 1)),
          ))
        ]));
  }
}
