import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/util/focal_point_to_alignment.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventRow extends StatefulWidget {
  const EventRow({
    Key? key,
    required this.event,
    required this.events,
    required this.isCompleted,
    required this.activeDateTime,
  }) : super(key: key);

  final EventModel event;
  final List<EventModel> events;
  final bool isCompleted;
  final DateTime activeDateTime;

  @override
  State<EventRow> createState() => EventRowState();
}

class EventRowState extends State<EventRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.key == widget.key &&
        oldWidget.isCompleted == widget.isCompleted) return;

    _scaleController.reset();
    Timer(const Duration(milliseconds: 200), () => _scaleController.forward());
  }

  @override
  void initState() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    Timer(const Duration(milliseconds: 200), () => _scaleController.forward());
    super.initState();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String startTime =
        DateFormat('hh:mm').format(widget.event.startDateTime.toLocal());
    String amPm = DateFormat('a').format(widget.event.startDateTime.toLocal());

    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/event',
              arguments: EventScreenArgs(
                  eventId: widget.event.id,
                  activeDateTime: widget.activeDateTime));
        },
        child: PrimaryCard(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: EdgeInsets.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            child: Column(children: [
              if (widget.event.image != null)
                Stack(children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 161, 210, 198)),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        alignment: focalPointToAlignment(
                            widget.event.image?.focalPoint),
                        // progressIndicatorBuilder: (context, url,
                        //         downloadProgress) =>
                        //     CircularProgressIndicator(color: theme.primaryColor),
                        imageUrl: getCloudflareImageUrl(
                            widget.event.image!.remoteImageId,
                            width: 800)),
                  ),
                  if (widget.isCompleted)
                    Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(color: Colors.black.withOpacity(0.8))),
                  if (widget.isCompleted)
                    Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Center(
                            child: ScaleTransition(
                                scale: Tween(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                        parent: _scaleController,
                                        curve: Curves.elasticOut)),
                                child: Stack(children: [
                                  Center(
                                      child: Icon(
                                    Icons.star_purple500_sharp,
                                    color: theme.primaryColor,
                                    size: 150,
                                  )),
                                  const Positioned(
                                      top: 8,
                                      left: 0,
                                      bottom: 0,
                                      right: 0,
                                      child: Center(
                                          child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 50,
                                      )))
                                ])))),
                ]),
              IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Container(
                        color: Color.fromARGB(255, 75, 129, 135),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Paragraph(startTime,
                                  color: Colors.white, bold: true),
                              Paragraph(amPm, color: Colors.white, bold: true)
                            ])),
                    Flexible(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: H1(widget.event.title, center: false)))),
                  ]))
            ])));
  }
}
