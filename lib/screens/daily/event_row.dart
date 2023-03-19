import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/h2.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/util/generate_invite_token%20copy.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventRow extends StatelessWidget {
  const EventRow({
    Key? key,
    required this.event,
    required this.events,
    required this.nextCalItemIndex,
  }) : super(key: key);

  final EventModel event;
  final List<EventModel> events;
  final int nextCalItemIndex;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // var isNextCalItem = nextCalItemIndex == -1
    //     ? false
    //     : events[nextCalItemIndex].id == event.id;
    String startTime =
        DateFormat('hh:mm a').format(event.startDateTime.toLocal());
    // String endTime = DateFormat('hh:mm a').format(
    //     event.startDateTime.toLocal().add(Duration(minutes: event.duration)));
    inspect(event);
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/event',
              arguments: EventScreenArgs(eventId: event.id));
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
              if (event.image != null)
                Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 125,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      // borderRadius: BorderRadius.circular(8),
                      color: Color.fromARGB(255, 161, 210, 198)),
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      alignment: focalPointToAlignment(event.image?.focalPoint),
                      // progressIndicatorBuilder: (context, url,
                      //         downloadProgress) =>
                      //     CircularProgressIndicator(color: theme.primaryColor),
                      imageUrl: getCloudflareImageUrl(
                          event.image!.remoteImageId,
                          width: 800)),
                ),
              // Icon(
              //   event.isComplete
              //       ? Icons.task_alt_rounded
              //       : isNextCalItem
              //           ? Icons.double_arrow_rounded
              //           : Icons.schedule_rounded,
              //   size: 50.0,
              //   color: event.isComplete
              //       ? theme.primaryColor
              //       : isNextCalItem
              //           ? theme.primaryColor
              //           : Colors.grey[400],
              // ),
              Container(
                  // margin: const EdgeInsets.only(left: 24),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        H1(event.title),
                        Paragraph(startTime),
                      ]))
            ])));
  }
}
