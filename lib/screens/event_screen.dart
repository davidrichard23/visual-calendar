import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/completed.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/models/event_task_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:realm/realm.dart';

class EventScreen extends StatefulWidget {
  final ObjectId eventId;

  const EventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.89,
  );
  late ConfettiController _confettiController;
  EventModel? event;
  List<EventTask>? tasks;
  bool didFetchEvent = false;
  bool isCompletedVisible = false;
  int currentPage = 0;

  // fixes hot reload issue
  @override
  void reassemble() {
    super.reassemble();
    event = null;
    tasks = null;
    didFetchEvent = false;
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 2000));
    currentPage = 0;
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (didFetchEvent) return;

    didFetchEvent = true;

    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    var newEvent = EventModel.get(realmManager.realm!, widget.eventId);
    newEvent!.sortTasks();

    setState(() {
      event = newEvent;
      tasks = newEvent.tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void showCompleted() {
      setState(() {
        isCompletedVisible = true;
      });
      _confettiController.play();
      Timer(const Duration(milliseconds: 7000), () {
        if (mounted) {
          setState(() {
            isCompletedVisible = false;
          });
          Navigator.pop(context);
        }
      });
    }

    if (event == null) return Container();

    Widget page({EventModel? event, EventTask? task, int? taskIndex}) {
      final dynamic pageItem = event ?? task;
      final padding = tasks == null || tasks!.isEmpty ? 0.0 : 12.0;

      return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: SafeArea(
              child: MaxWidth(
                  maxWidth: maxWidth,
                  child: Column(children: [
                    if (pageItem!.image != null)
                      Container(
                        // margin: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromARGB(255, 161, 210, 198)),
                        child: CachedNetworkImage(
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                                    child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                            color: theme.primaryColor))),
                            imageUrl: getCloudflareImageUrl(
                                pageItem!.image!.remoteImageId,
                                width: 800)),
                      ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                        child: Column(
                          children: [
                            PrimaryCard(
                                margin: EdgeInsets.zero,
                                child: Column(children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 16),
                                    child: Center(child: H1(pageItem!.title)),
                                  ),
                                  Paragraph(pageItem!.description),
                                ])),
                            event != null /* && !event!.isComplete */
                                ? Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                    child: PrimaryButton(
                                        onPressed: () {
                                          if (tasks != null &&
                                              tasks!.isNotEmpty) {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              curve: Curves.easeInOut,
                                            );
                                          } else {
                                            showCompleted();
                                          }
                                        },
                                        child: Text(
                                            tasks != null && tasks!.isNotEmpty
                                                ? 'Start!'
                                                : 'Finish!')))
                                : Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                    child: PrimaryButton(
                                        onPressed: () {
                                          if (taskIndex == tasks!.length - 1) {
                                            showCompleted();
                                            return;
                                          }
                                          _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Text(
                                            taskIndex == tasks!.length - 1
                                                ? 'Finish!'
                                                : 'Complete!')))
                          ],
                        ))
                  ]))));
    }

    final pages = [page(event: event)];
    if (tasks != null) {
      for (var i = 0; i < tasks!.length; i++) {
        pages.add(page(task: tasks![i], taskIndex: i));
      }
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
            foregroundColor: Colors.grey[800],
            backgroundColor: theme.backgroundColor,
            elevation: 0),
        body: Stack(children: [
          PageView(
            controller: _pageController,
            children: pages,
          ),
          Completed(_confettiController, isCompletedVisible),
        ]));
  }
}
