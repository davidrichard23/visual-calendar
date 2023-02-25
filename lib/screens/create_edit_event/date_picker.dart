import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePicker extends StatefulWidget {
  final DateTime dateTime;
  final Function(DateTime) setDateTime;

  const DatePicker(
      {Key? key, required this.dateTime, required this.setDateTime})
      : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool showDatePicker = false;

  toggleDatePicker() {
    setState(() {
      showDatePicker = !showDatePicker;
    });
  }

  onDateChange(DateRangePickerSelectionChangedArgs args) {
    widget.setDateTime(args.value);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggleDatePicker,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Start Date',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            DateFormat('EEE MMMM d, y').format(widget.dateTime))
                      ]))),
          ExpandedableWidget(
              expand: showDatePicker,
              child: Column(children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 1,
                    color: Colors.grey[200]),
                SfDateRangePicker(
                  showNavigationArrow: true,
                  headerStyle: DateRangePickerHeaderStyle(
                      textStyle: TextStyle(color: Colors.grey[700])),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          textStyle: TextStyle(color: Colors.grey[500]))),
                  onSelectionChanged: onDateChange,
                )
              ]))
        ]));
  }
}
