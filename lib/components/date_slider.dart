import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

const maxDayCount = 50;

class DateSlider extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) setSelectedDate;
  const DateSlider(this.selectedDate, this.setSelectedDate, {Key? key})
      : super(key: key);

  @override
  State<DateSlider> createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  final List<DateTime> dateList = [];
  late AutoScrollController controller;
  final scrollDirection = Axis.horizontal;

  @override
  void initState() {
    super.initState();

    controller = AutoScrollController(axis: scrollDirection);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.scrollToIndex((maxDayCount ~/ 2),
          preferPosition: AutoScrollPosition.middle);
    });

    var now = DateTime.now();
    dateList.add(now);

    for (var i = 1; i <= maxDayCount / 2; i++) {
      var newDate = now.add(Duration(days: i));
      dateList.add(newDate);
    }

    for (var i = 1; i <= maxDayCount / 2; i++) {
      var newDate = now.subtract(Duration(days: i));
      dateList.insert(0, newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
                top:
                    BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.1)))),
        child: SizedBox(
            height: 58,
            child: ListView.builder(
              controller: controller,
              scrollDirection: scrollDirection,
              itemCount: dateList.length,
              itemBuilder: (context, index) {
                var date = dateList[index];
                var isSelected = date.day == widget.selectedDate.day;
                var dayOfWeek = DateFormat('E').format(date);
                var dayNumber = date.day.toString();

                return AutoScrollTag(
                    key: ValueKey(index),
                    controller: controller,
                    index: index,
                    child: GestureDetector(
                        onTap: () => widget.setSelectedDate(date),
                        child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? theme.primaryColor
                                    : Colors.transparent),
                            child: Column(children: [
                              Text(
                                dayOfWeek,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey),
                              ),
                              Text(
                                dayNumber,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey),
                              ),
                            ]))));
              },
            )));
  }
}
