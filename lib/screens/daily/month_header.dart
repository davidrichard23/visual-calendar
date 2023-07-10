import 'dart:developer';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MonthHeader extends StatelessWidget {
  const MonthHeader({
    Key? key,
    required this.date,
    required this.calendarViewMode,
    required this.selectedView,
    required this.setCalendarViewMode,
    required this.setActiveDate,
  }) : super(key: key);

  final DateTime date;
  final CalendarView? calendarViewMode;
  final String selectedView;
  final Function(CalendarView) setCalendarViewMode;
  final Function(DateTime) setActiveDate;

  void handleChangeDate(int delta) {
    final newDate = calendarViewMode == CalendarView.month
        ? DateTime(date.year, date.month + delta, date.day)
        : DateTime(date.year, date.month, date.day + delta);
    setActiveDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format =
        calendarViewMode == CalendarView.month && selectedView == 'manage'
            ? 'MMMM y'
            : 'd MMMM y';

    return Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
            onTap: () => setCalendarViewMode(CalendarView.month),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(
                  width: 50,
                  child: IconButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      onPressed: () => handleChangeDate(-1),
                      icon: const Icon(Icons.chevron_left))),
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: theme.backgroundColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: H1(
                          DateFormat(format).format(date),
                          center: true,
                          color: const Color.fromRGBO(0, 69, 77, 1),
                        ),
                      ))),
              SizedBox(
                  width: 50,
                  child: IconButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      onPressed: () => handleChangeDate(1),
                      icon: const Icon(Icons.chevron_right))),
            ])));
  }
}
