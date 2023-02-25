import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/completed.dart';
import 'package:calendar/components/confetti.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/models/event_task_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class EventTaskScreen extends StatefulWidget {
  final EventModel event;

  const EventTaskScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventTaskScreen> createState() => _EventTaskScreenState();
}

class _EventTaskScreenState extends State<EventTaskScreen> {
  late ConfettiController _confettiController;
  List<EventTaskModel> eventTasks = [];
  int activeTaskIndex = 0;
  bool isCompletedVisible = false;

  // fixes hot reload issue
  @override
  void reassemble() {
    super.reassemble();
    eventTasks = [];
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Realm realm = Provider.of<Realm>(context, listen: true);
    final theme = Theme.of(context);

    onUpdate<T extends RealmObject>(RealmResults<T> newTasks) {
      final sorted =
          newTasks.map((e) => EventTaskModel(realm, e as EventTask)).toList();
      // sorted.sort((a, b) => a.order - b.order);

      // final i = sorted.indexWhere((task) => !task.isComplete);
      const i = 0;

      setState(() {
        eventTasks = sorted;
        activeTaskIndex = i != -1 ? i : activeTaskIndex;
      });
    }

    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Welcome to Flutter'),
        // ),
        backgroundColor: theme.backgroundColor,
        body: RealmQueryBuilder<EventTask>(
            onUpdate: onUpdate,
            queryName: 'listEventTasks-${widget.event.id}',
            queryType: QueryType.queryString,
            queryString: 'event == "${widget.event.id}"',
            child: Builder(builder: ((context) {
              if (!eventTasks.isNotEmpty) return Container();

              final activeTask = eventTasks[activeTaskIndex];
              final totalTaskCount = eventTasks.length;
              // final completedTaskCount =
              //     eventTasks.where((task) => task.isComplete).length;
              final completedTaskCount = 0;
              final progress = completedTaskCount / totalTaskCount;

              return Stack(children: [
                SafeArea(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        height: MediaQuery.of(context).size.height - 24,
                        child: Column(children: [
                          PrimaryCard(
                              child: Row(children: [
                            CircularPercentIndicator(
                              animation: true,
                              radius: 50.0,
                              lineWidth: 10.0,
                              percent: progress,
                              // header: const Text("Icon header"),
                              center: const Icon(
                                Icons.task_alt_rounded,
                                size: 40.0,
                                color: Colors.green,
                              ),
                              backgroundColor: Colors.black12,
                              progressColor: theme.primaryColor,
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const H1('Your Progress'),
                                          Paragraph(
                                              'You have completed $completedTaskCount tasks and have ${totalTaskCount - completedTaskCount} tasks left',
                                              small: true)
                                        ]))),
                          ])),
                          activeTask.image != null
                              ? Container(
                                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(activeTask.image!,
                                      fit: BoxFit.cover))
                              : Container(),
                          PrimaryCard(
                              child: Column(children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: Center(child: H1(activeTask.title)),
                            ),
                            Paragraph(activeTask.description),
                          ])),
                          // Container(
                          //     margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          //     child: PrimaryButton(
                          //         onPressed: () {
                          //           if (eventTasks
                          //                   .where((task) => !task.isComplete)
                          //                   .length >
                          //               1) {
                          //             setState(() {
                          //               activeTaskIndex++;
                          //             });
                          //             activeTask.complete();
                          //           } else {
                          //             activeTask.complete();
                          //             widget.event.complete();
                          //             setState(() {
                          //               isCompletedVisible = true;
                          //             });
                          //             _confettiController.play();
                          //             Timer(const Duration(milliseconds: 7000),
                          //                 () {
                          //               Navigator.popUntil(context,
                          //                   ModalRoute.withName('/daily'));
                          //               setState(() {
                          //                 isCompletedVisible = false;
                          //               });
                          //             });
                          //           }
                          //         },
                          //         child: const Text('Complete Task'))),
                        ]))),
                Completed(_confettiController, isCompletedVisible),
              ]);
            }))));
  }
}
