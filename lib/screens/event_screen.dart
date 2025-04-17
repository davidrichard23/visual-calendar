import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/completed.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/extensions/date_utils.dart';
import 'package:calendar/models/completion_record_model.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class EventScreen extends StatefulWidget {
  final ObjectId eventId;
  final DateTime activeDateTime;

  const EventScreen(
      {Key? key, required this.eventId, required this.activeDateTime})
      : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final Completer<GoogleMapController> gMapsController =
      Completer<GoogleMapController>();
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

  void showCompleted() {
    createCompletionRecord();

    setState(() {
      isCompletedVisible = true;
    });
    _confettiController.play();
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() {
          isCompletedVisible = false;
        });
        Navigator.pop(context);
      }
    });
  }

  void createCompletionRecord() {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);
    AppServices appServices = Provider.of<AppServices>(context, listen: false);

    final recurringInstanceDateTime =
        event!.isRecurring ? widget.activeDateTime.startOfDay : null;
    CompletionRecordModel.create(
        realmManager.realm!,
        CompletionRecord(ObjectId(), widget.eventId, appState.activeTeam!.id,
            ObjectId.fromHexString(appServices.currentUser!.id),
            recurringInstanceDateTime: recurringInstanceDateTime));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (event == null) return Container();

    Widget page({EventModel? event, EventTask? task, int? taskIndex}) {
      final dynamic pageItem = event ?? task;
      final padding = tasks == null || tasks!.isEmpty ? 0.0 : 12.0;
      final latLng =
          LatLng(event?.location?.lat ?? 0, event?.location?.long ?? 0);

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
                                  Center(child: H1(pageItem!.title)),
                                  if (pageItem!.description != '')
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 16, 0, 0),
                                        child:
                                            Paragraph(pageItem!.description)),
                                ])),
                            if (event != null && event.location != null)
                              PrimaryCard(
                                  padding: EdgeInsets.zero,
                                  margin: const EdgeInsets.only(
                                      top: 16, bottom: 0, left: 0, right: 0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  child: SizedBox(
                                      height: 200,
                                      child: GoogleMap(
                                        myLocationButtonEnabled: false,
                                        markers: {
                                          Marker(
                                              markerId:
                                                  MarkerId(event.id.toString()),
                                              position: latLng)
                                        },
                                        initialCameraPosition: CameraPosition(
                                            zoom: 14, target: latLng),
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          if (!gMapsController.isCompleted) {
                                            gMapsController
                                                .complete(controller);
                                          }
                                        },
                                      ))),
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
