// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/screens/create_edit_event/date_picker.dart';
import 'package:calendar/screens/create_edit_event/image_picker.dart';
import 'package:calendar/screens/create_edit_event/location_picker.dart';
import 'package:calendar/screens/create_edit_event/repeat_picker.dart';
import 'package:calendar/screens/create_edit_event/task_list.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

Map<String, String> frequencyToRecurrenceType = {
  'days': 'daily',
  'weeks': 'weekly',
  'months': 'monthly',
  'years': 'yearly'
};
Map<String, String> recurrenceTypeToFrequency = {
  'daily': 'days',
  'weekly': 'weeks',
  'monthly': 'months',
  'yearly': 'years'
};
Map<String, int> weekdayToInt = {
  'monday': 1,
  'tuesday': 2,
  'wednesday': 3,
  'thursday': 4,
  'friday': 5,
  'saturday': 6,
  'sunday': 7,
};
Map<int, String> intToWeekday = {
  1: 'monday',
  2: 'tuesday',
  3: 'wednesday',
  4: 'thursday',
  5: 'friday',
  6: 'saturday',
  7: 'sunday',
};

class StagedImageData {
  final ObjectId? taskId;
  final ImageData? image;

  StagedImageData({this.taskId, this.image});
}

enum OpenPicker {
  none,
  location,
  startDate,
  startTime,
  duration,
  repeat,
}

class CreateEditEvent extends StatefulWidget {
  final EventModel? existingEvent;
  final EventModel? templateEvent;
  final DateTime? initalStartDate;
  final int? initalDuration;
  final id = ObjectId();

  CreateEditEvent(
      {Key? key,
      this.existingEvent,
      this.templateEvent,
      this.initalStartDate,
      this.initalDuration})
      : super(key: key);

  @override
  State<CreateEditEvent> createState() => _CreateEditEventState();
}

class _CreateEditEventState extends State<CreateEditEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<EventTask> tasks = [];
  final List<StagedImageData> stagedImages = [];
  OpenPicker openPicker = OpenPicker.none;

  bool isLoading = false;
  String? error;

  int selectedInterval = 0;
  String selectedFrequency = 'days';
  List<String> selectedWeekdays = [];
  DateTime recurringEndDateTime = DateTime(9999);

  String title = '';
  String description = '';
  LocationData? location;
  DateTime? startDateTime;
  int duration = 60;
  bool isTemplate = false;

  String eventEndMode = 'duration';
  DateTime endTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.existingEvent == null) {
      if (widget.initalStartDate != null) {
        startDateTime = widget.initalStartDate!.nearestFiveMins;
        selectedWeekdays.add(intToWeekday[startDateTime!.weekday]!);
      }
      if (widget.initalDuration != null) {
        duration = widget.initalDuration!;
      }

      endTime = startDateTime!.add(Duration(minutes: duration));

      if (widget.templateEvent != null) {
        widget.templateEvent!.sortTasks();

        title = widget.templateEvent!.title;
        description = widget.templateEvent!.description;
        location = widget.templateEvent!.location;
        duration = widget.templateEvent!.duration;
        tasks = widget.templateEvent!.duplicateTasks(widget.id);
        stagedImages.add(StagedImageData(image: widget.templateEvent!.image));
        for (var task in tasks) {
          stagedImages.add(StagedImageData(taskId: task.id, image: task.image));
        }
      }

      return;
    }

    widget.existingEvent!.sortTasks();
    title = widget.existingEvent!.title;
    description = widget.existingEvent!.description;
    location = widget.existingEvent!.location;
    startDateTime = widget.existingEvent!.startDateTime.toLocal();
    selectedWeekdays.add(intToWeekday[startDateTime!.weekday]!);
    duration = widget.existingEvent!.duration;
    tasks = widget.existingEvent!.tasks.toList();
    endTime = startDateTime!.add(Duration(minutes: duration));
    isTemplate = widget.existingEvent!.isTemplate;

    stagedImages.add(StagedImageData(image: widget.existingEvent!.image));
    for (var task in tasks) {
      stagedImages.add(StagedImageData(taskId: task.id, image: task.image));
    }

    final recurrencePattern = widget.existingEvent!.recurrencePattern;

    if (recurrencePattern == null) return;

    selectedInterval = recurrencePattern.interval;
    selectedFrequency =
        recurrenceTypeToFrequency[recurrencePattern.recurrenceType]!;
    selectedWeekdays =
        recurrencePattern.daysOfWeek.map((e) => intToWeekday[e]!).toList();
    recurringEndDateTime = recurrencePattern.endDateTime;
  }

  void toggleOpenPicker(OpenPicker picker) {
    setState(
        () => openPicker = openPicker == picker ? OpenPicker.none : picker);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  onLocationChange(LocationData locationData) {
    setState(() => location = locationData);
  }

  onStartDateChange(DateTime d) {
    var newDate = DateTime(
        d.year, d.month, d.day, startDateTime!.hour, startDateTime!.minute);
    setState(() {
      startDateTime = newDate;
      selectedWeekdays.add(intToWeekday[startDateTime!.weekday]!);
      endTime = newDate.add(Duration(minutes: duration));
    });
  }

  onStartTimeChange(DateTime time) {
    var newDate = DateTime(startDateTime!.year, startDateTime!.month,
        startDateTime!.day, time.hour, time.minute);
    setState(() {
      startDateTime = newDate;
      endTime = newDate.add(Duration(minutes: duration));
    });
  }

  onEndTimeChange(DateTime time) {
    var newDate = DateTime(startDateTime!.year, startDateTime!.month,
        startDateTime!.day, time.hour, time.minute);

    setState(() {
      endTime = newDate;
      if (newDate.isAfter(startDateTime!)) {
        duration = newDate.difference(startDateTime!).inMinutes;
      }
    });
  }

  onEventEndModeChange(value) {
    setState(() {
      eventEndMode = value;
    });
  }

  onDurationChange(Duration newDuration) {
    setState(() {
      duration = newDuration.inMinutes;
      endTime = startDateTime!.add(Duration(minutes: newDuration.inMinutes));
    });
  }

  setSelectedInterval(int interval) {
    setState(() {
      selectedInterval = interval;
    });
  }

  setSelectedFrequency(String frequency) {
    setState(() {
      selectedFrequency = frequency;
    });
  }

  setSelectedWeekdays(List<String> weekdays) {
    setState(() {
      selectedWeekdays = weekdays;
    });
  }

  setRecurringEndDateTime(DateTime d) {
    setState(() {
      recurringEndDateTime = d;
    });
  }

  setEventImage(ImageData? image) {
    final existing =
        stagedImages.firstWhereOrNull((element) => element.taskId == null);
    if (existing == null) {
      setState(() {
        stagedImages.add(StagedImageData(taskId: null, image: image));
      });
    } else {
      final index =
          stagedImages.indexWhere((element) => element.taskId == null);
      setState(() {
        stagedImages.replaceRange(
            index, index + 1, [StagedImageData(taskId: null, image: image)]);
      });
    }
  }

  setTaskImage(ObjectId taskId, ImageData? image) {
    final existing =
        stagedImages.firstWhereOrNull((element) => element.taskId == taskId);
    if (existing == null) {
      setState(() {
        stagedImages.add(StagedImageData(taskId: taskId, image: image));
      });
    } else {
      final index =
          stagedImages.indexWhere((element) => element.taskId == taskId);
      setState(() {
        stagedImages.replaceRange(
            index, index + 1, [StagedImageData(taskId: taskId, image: image)]);
      });
    }
  }

  stageAddTask(EventTask task) {
    setState(() {
      tasks.add(task);
    });
  }

  stageUpdateTask(EventTask task) {
    var newTasks = tasks.map((origTask) {
      if (task.id == origTask.id) return task;
      return origTask;
    }).toList();

    setState(() {
      tasks = newTasks;
    });
  }

  stageReorderTask(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      // moving the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }

    tasks.move(oldIndex, newIndex);

    setState(() {
      tasks = tasks;
    });
  }

  void stageRemoveTask(int i) {
    stagedImages.removeWhere((image) => image.taskId == tasks[i].id);
    tasks.removeAt(i);

    setState(() {
      tasks = tasks;
    });
  }

  handleDelete() async {
    bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(false); // dismisses only the dialog and returns false
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(true); // dismisses only the dialog and returns true
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result) {
      widget.existingEvent!.delete();
      Navigator.popUntil(
          context, (predicate) => predicate.settings.name == '/home');
    }
  }

  handleSaveEvent() async {
    final appState = Provider.of<AppState?>(context, listen: false);
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: false);
    final currentUser =
        Provider.of<AppServices>(context, listen: false).currentUser;
    final isFormValid = _formKey.currentState!.validate();

    var isEndTimeAfterStartTime = endTime.isAfter(startDateTime!);
    if (eventEndMode == 'endTime' && !isEndTimeAfterStartTime) {
      showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('End time must be greater than start time'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return;
    }

    if (isFormValid) {
      _formKey.currentState!.save();

      try {
        setState(() => isLoading = true);

        final stagedEventImage =
            stagedImages.firstWhereOrNull((i) => i.taskId == null);
        final stagedTaskImages = stagedImages.where((i) => i.taskId != null);

        for (var stagedImage in stagedTaskImages) {
          final t = tasks.firstWhere((task) {
            return task.id == stagedImage.taskId;
          });
          t.image = stagedImage.image;
        }

        var recurrencePattern = getRecurrencePattern();

        if (widget.existingEvent == null) {
          var event = Event(
              widget.id,
              appState!.activeTeam!.id,
              ObjectId.fromHexString(currentUser!.id),
              title,
              description,
              startDateTime!.toUtc(),
              duration,
              recurrencePattern != null,
              image: stagedEventImage?.image,
              location: location,
              isTemplate: isTemplate,
              recurrencePattern: recurrencePattern);

          EventModel.create(realmManager.realm!, event, tasks);
        } else {
          widget.existingEvent!.update(
              title: title,
              description: description,
              startDateTime: startDateTime,
              duration: duration,
              isRecurring: recurrencePattern != null,
              image: stagedEventImage?.image,
              location: location,
              isTemplate: isTemplate,
              recurrencePattern: recurrencePattern,
              tasks: tasks);
        }

        setState(() => isLoading = false);
        Navigator.popUntil(
            context, (predicate) => predicate.settings.name == '/home');
      } on AppException catch (err) {
        setState(() {
          error = err.message;
          isLoading = false;
        });
      }
    }
  }

  RecurrencePattern? getRecurrencePattern() {
    var type = frequencyToRecurrenceType[selectedFrequency];
    var doesEnd = recurringEndDateTime.year != 9999;
    var weekdayInts = selectedWeekdays.map((e) => weekdayToInt[e]!).toList();
    List<int> daysOfWeek = [];
    List<int> daysOfMonth = [];
    List<int> weeksOfMonth = [];
    List<int> monthsOfYear = [];

    switch (type) {
      case 'weekly':
        daysOfWeek = weekdayInts;
        break;
      case 'monthly':
        daysOfMonth = [startDateTime!.day]; // TODO: multiple days
        break;
      case 'yearly':
        monthsOfYear = [startDateTime!.month]; // TODO: multiple months
        daysOfMonth.add(startDateTime!.day);
        break;
      default:
    }
    var recurrencePattern = selectedInterval == 0
        ? null
        : RecurrencePattern(ObjectId(), type!, selectedInterval, startDateTime!,
            recurringEndDateTime, doesEnd,
            daysOfWeek: daysOfWeek,
            daysOfMonth: daysOfMonth,
            weeksOfMonth: weeksOfMonth,
            monthsOfYear: monthsOfYear);

    return recurrencePattern;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stagedEventImage =
        stagedImages.firstWhereOrNull((i) => i.taskId == null);
    var durationObj = Duration(minutes: duration);
    var hours = durationObj.inHours;
    var minutes = durationObj.inMinutes - 60 * hours;
    var isEndTimeAfterStartTime = endTime.isAfter(startDateTime!);
    var durationString =
        '${hours > 0 ? '$hours' '${hours == 1 ? ' hour' : ' hours'}' : ''} ${minutes > 0 ? '$minutes' '${minutes == 1 ? ' minute' : ' minutes'}' : ''}';
    var durationStrColor =
        (eventEndMode == 'endTime' && !isEndTimeAfterStartTime)
            ? Colors.red
            : theme.textTheme.bodyLarge!.color;

    return Stack(children: [
      Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
              title: Text(
                widget.existingEvent == null ? 'Create Event' : 'Edit Event',
                style: TextStyle(color: Colors.black.withOpacity(0.7)),
              ),
              foregroundColor: Color.fromRGBO(17, 182, 141, 1),
              backgroundColor: theme.backgroundColor,
              elevation: 0,
              actions: [
                TextButton(
                    onPressed: handleSaveEvent,
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromRGBO(17, 182, 141, 1),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    child:
                        Text(widget.existingEvent == null ? 'Create' : 'Save'))
              ]),
          body: SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.only(top: 12),
                  width: double.infinity,
                  child: MaxWidth(
                    maxWidth: maxWidth,
                    child: Column(children: [
                      if (error != null)
                        Text(
                          'Error: ${error!}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      ImagePickerWidget(
                        image: stagedEventImage?.image,
                        setImage: setEventImage,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(
                                hintText: 'Title',
                                initialValue: title,
                                textInputAction: TextInputAction.done,
                                onSaved: (String? value) {
                                  if (value == null) return;
                                  title = value;
                                },
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextFormField(
                                minLines: 4,
                                maxLines: 4,
                                hintText: 'Description',
                                initialValue: description,
                                onSaved: (String? value) {
                                  if (value == null) return;
                                  description = value;
                                },
                              ),
                            ]),
                      ),
                      LocationPicker(
                          isOpen: openPicker == OpenPicker.location,
                          setExpanded: toggleOpenPicker,
                          selectedLocation: location,
                          setLocation: onLocationChange),
                      Container(height: 16),
                      PrimaryCard(
                          padding: EdgeInsets.zero,
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  setState(() => isTemplate = !isTemplate),
                              child: Row(children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.all(
                                      theme.primaryColor),
                                  value: isTemplate,
                                  onChanged: (bool? value) =>
                                      setState(() => isTemplate = !isTemplate),
                                ),
                                Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 8, bottom: 8, right: 8),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                  'Save this event as a template?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Flexible(
                                                  child: Text(
                                                      'A template allows you to quickly create a copy of this event in the future. This is useful for irregular repeating events.',
                                                      style: TextStyle(
                                                          fontSize: 11))),
                                            ])))
                              ]))),
                      Container(height: 16),
                      DatePicker(
                          isOpen: openPicker == OpenPicker.startDate,
                          setExpanded: toggleOpenPicker,
                          dateTime: startDateTime!,
                          setDateTime: onStartDateChange),
                      PrimaryCard(
                          padding: EdgeInsets.zero,
                          child: Column(children: [
                            GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    toggleOpenPicker(OpenPicker.startTime),
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Start Time',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(DateFormat('h:mm a')
                                              .format(startDateTime!))
                                        ]))),
                            ExpandedableWidget(
                                expand: openPicker == OpenPicker.startTime,
                                curve: Curves.easeInOut,
                                child: Column(children: [
                                  Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      height: 1,
                                      color: Colors.grey[200]),
                                  SizedBox(
                                      height: 200,
                                      width: 180,
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        initialDateTime: startDateTime,
                                        minuteInterval: 5,
                                        onDateTimeChanged: onStartTimeChange,
                                      ))
                                ]))
                          ])),
                      PrimaryCard(
                          padding: EdgeInsets.zero,
                          child: Column(children: [
                            GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    toggleOpenPicker(OpenPicker.duration),
                                child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Text('Duration',
                                          //     style: TextStyle(
                                          //         fontWeight: FontWeight.bold)),
                                          CupertinoSlidingSegmentedControl(
                                            backgroundColor:
                                                theme.backgroundColor,
                                            thumbColor: theme.primaryColor,
                                            groupValue: eventEndMode,
                                            onValueChanged:
                                                onEventEndModeChange,
                                            children: const {
                                              'duration': Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text(
                                                  'Duration',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          0, 69, 77, 1)),
                                                ),
                                              ),
                                              'endTime': Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Text(
                                                  'End Time',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          0, 69, 77, 1)),
                                                ),
                                              )
                                            },
                                          ),
                                          Text(
                                            eventEndMode == 'duration'
                                                ? durationString
                                                : DateFormat('h:mm a')
                                                    .format(endTime),
                                            style: TextStyle(
                                                color: durationStrColor),
                                          )
                                        ]))),
                            ExpandedableWidget(
                                expand: openPicker == OpenPicker.duration,
                                curve: Curves.easeInOut,
                                child: eventEndMode == 'duration'
                                    ? Column(children: [
                                        Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            height: 1,
                                            color: Colors.grey[200]),
                                        SizedBox(
                                            width: 220,
                                            child: CupertinoTimerPicker(
                                              mode: CupertinoTimerPickerMode.hm,
                                              minuteInterval: 5,
                                              initialTimerDuration:
                                                  Duration(minutes: duration),
                                              onTimerDurationChanged:
                                                  onDurationChange,
                                            ))
                                      ])
                                    : Column(children: [
                                        Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            height: 1,
                                            color: Colors.grey[200]),
                                        SizedBox(
                                            height: 200,
                                            width: 180,
                                            child: CupertinoDatePicker(
                                              mode:
                                                  CupertinoDatePickerMode.time,
                                              initialDateTime: endTime,
                                              minuteInterval: 5,
                                              onDateTimeChanged:
                                                  onEndTimeChange,
                                            ))
                                      ]))
                          ])),
                      RepeatPicker(
                          isOpen: openPicker == OpenPicker.repeat,
                          setExpanded: toggleOpenPicker,
                          selectedInterval: selectedInterval,
                          selectedFrequency: selectedFrequency,
                          selectedWeekdays: selectedWeekdays,
                          setSelectedInterval: setSelectedInterval,
                          setSelectedFrequency: setSelectedFrequency,
                          setSelectedWeekdays: setSelectedWeekdays,
                          endDateTime: recurringEndDateTime,
                          setEndDateTime: setRecurringEndDateTime),
                      Container(height: 16),
                      TaskList(
                        tasks: tasks,
                        images: stagedImages,
                        stageAddTask: stageAddTask,
                        stageUpdateTask: stageUpdateTask,
                        reorderTask: stageReorderTask,
                        removeTask: stageRemoveTask,
                        setImage: setTaskImage,
                        // removeImage: removeImage,
                        eventId: (widget.existingEvent == null
                                ? widget.id
                                : widget.existingEvent!.id)
                            .toString(),
                      ),
                      if (widget.existingEvent != null)
                        Padding(
                            padding: EdgeInsets.all(16),
                            child: PrimaryButton(
                                medium: true,
                                onPressed: handleDelete,
                                color: const Color.fromARGB(255, 255, 117, 107),
                                child: const Text('Delete'))),
                      Container(height: 200),
                    ]),
                  )))),
      if (isLoading)
        Positioned(
            top: 0,
            left: 0,
            height: MediaQuery.of(context).size.height,
            right: 0,
            child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                    )
                  ],
                )))
    ]);
  }
}
