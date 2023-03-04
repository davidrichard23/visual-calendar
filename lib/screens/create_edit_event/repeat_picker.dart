import 'dart:developer';

import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/screens/create_edit_event/date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:calendar/extensions/list_utils.dart';

var repeatIntervalList = List<int>.generate(100, (i) => i);
var repeatFrequencyList = ['days', 'weeks', 'months', 'years'];
var weekdayList = [
  'sunday',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday'
];

class RepeatPicker extends StatefulWidget {
  final bool isOpen;
  final void Function(OpenPicker) setExpanded;
  final int selectedInterval;
  final String selectedFrequency;
  final List<String> selectedWeekdays;
  final Function(int) setSelectedInterval;
  final Function(String) setSelectedFrequency;
  final Function(List<String>) setSelectedWeekdays;
  final DateTime endDateTime;
  final Function(DateTime) setEndDateTime;

  const RepeatPicker(
      {Key? key,
      required this.isOpen,
      required this.setExpanded,
      required this.selectedInterval,
      required this.selectedFrequency,
      required this.selectedWeekdays,
      required this.setSelectedInterval,
      required this.setSelectedFrequency,
      required this.setSelectedWeekdays,
      required this.setEndDateTime,
      required this.endDateTime})
      : super(key: key);

  @override
  State<RepeatPicker> createState() => _RepeatPickerState();
}

class _RepeatPickerState extends State<RepeatPicker> {
  bool showEndDatePicker = false;

  toggleRepeatPicker() {
    widget.setExpanded(widget.isOpen ? OpenPicker.none : OpenPicker.repeat);
  }

  toggleEndDatePicker() {
    setState(() {
      showEndDatePicker = !showEndDatePicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adjustedFrequencyText = widget.selectedInterval == 1
        ? widget.selectedFrequency
            .substring(0, widget.selectedFrequency.length - 1)
        : widget.selectedFrequency;

    final repeatStr =
        'Every${widget.selectedInterval == 1 ? '' : ' ${widget.selectedInterval}'} $adjustedFrequencyText';
    final weekdayStr = widget.selectedFrequency != 'weeks'
        ? ''
        : ', on ${widget.selectedWeekdays.toOxfordListString}';
    final endDateStr = widget.endDateTime.year == 9999
        ? ''
        : ', until ${DateFormat('MMM d, y').format(widget.endDateTime)}';
    return PrimaryCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggleRepeatPicker,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: const Text('Repeat',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Flexible(
                            child: Text(widget.selectedInterval == 0
                                ? 'Never'
                                : '$repeatStr$weekdayStr$endDateStr'))
                      ]))),
          ExpandedableWidget(
              curve: Curves.easeInOut,
              expand: widget.isOpen,
              child: Column(children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 1,
                    color: Colors.grey[200]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      height: 200,
                      width: 50,
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: widget.selectedInterval),
                        onSelectedItemChanged: (int selectedItem) {
                          widget.setSelectedInterval(selectedItem);
                        },
                        children: List<Widget>.generate(
                            repeatIntervalList.length, (int index) {
                          return Center(
                            child: Text(
                              repeatIntervalList[index].toString(),
                            ),
                          );
                        }),
                      )),
                  SizedBox(
                      height: 200,
                      width: 100,
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: repeatFrequencyList
                                .indexOf(widget.selectedFrequency)),
                        onSelectedItemChanged: (int selectedItem) {
                          widget.setSelectedFrequency(
                              repeatFrequencyList[selectedItem]);
                        },
                        children: List<Widget>.generate(
                            repeatFrequencyList.length, (int index) {
                          return Center(
                            child: Text(
                              repeatFrequencyList[index].toString(),
                            ),
                          );
                        }),
                      ))
                ]),
                ExpandedableWidget(
                    expand: widget.selectedFrequency == 'weeks',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            height: 1,
                            color: Colors.grey[200]),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Every',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8)),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: -8,
                                    children: weekdayList
                                        .map((e) => InputChip(
                                            label: Text(e),
                                            showCheckmark: false,
                                            selectedColor: theme.primaryColor,
                                            selected: widget.selectedWeekdays
                                                .contains(e),
                                            onSelected: (bool selected) {
                                              List<String> newList = List.from(
                                                  widget.selectedWeekdays);
                                              if (selected) {
                                                newList.add(e);
                                              } else {
                                                newList.remove(e);
                                              }
                                              widget
                                                  .setSelectedWeekdays(newList);
                                            }))
                                        .toList(),
                                  )
                                ]))
                      ],
                    )),
                Column(children: [
                  Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 1,
                      color: Colors.grey[200]),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: toggleEndDatePicker,
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Repeat Ends',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(widget.endDateTime.year == 9999
                                    ? 'Never'
                                    : DateFormat('MMMM d, y')
                                        .format(widget.endDateTime))
                              ]))),
                  ExpandedableWidget(
                      expand: showEndDatePicker,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                height: 1,
                                color: Colors.grey[200]),
                            SfDateRangePicker(
                              // controller: dateRangeController,
                              showNavigationArrow: true,
                              headerStyle: DateRangePickerHeaderStyle(
                                  textStyle:
                                      TextStyle(color: Colors.grey[700])),
                              monthViewSettings:
                                  DateRangePickerMonthViewSettings(
                                      viewHeaderStyle:
                                          DateRangePickerViewHeaderStyle(
                                              textStyle: TextStyle(
                                                  color: Colors.grey[500]))),
                              initialSelectedDate: widget.endDateTime,
                              onSelectionChanged:
                                  (DateRangePickerSelectionChangedArgs args) {
                                widget.setEndDateTime(args.value);
                              },
                            ),
                            widget.endDateTime.year != 9999
                                ? ElevatedButton(
                                    onPressed: () {
                                      var newDate = DateTime(9999);
                                      widget.setEndDateTime(newDate);
                                      setState(() {
                                        showEndDatePicker = false;
                                      });
                                    },
                                    child: const Text('Remove End Date'))
                                : Container()
                          ]))
                ])
              ]))
        ]));
  }
}
