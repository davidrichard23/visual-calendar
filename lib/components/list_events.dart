import 'dart:developer';

import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class ListEvents extends StatefulWidget {
  const ListEvents({Key? key}) : super(key: key);

  @override
  State<ListEvents> createState() => _ListEventsState();
}

class _ListEventsState extends State<ListEvents> {
  List<EventModel> events = [];
  late Realm realm;

  // fixes hot reload issue
  @override
  void reassemble() {
    super.reassemble();
    events = [];
  }

  @override
  Widget build(BuildContext context) {
    realm = Provider.of<Realm>(context, listen: true);

    onUpdate<T extends RealmObject>(RealmResults<T> newEvents) {
      setState(() {
        events = newEvents.map((e) => EventModel(realm, e as Event)).toList();
      });
    }

    return RealmQueryBuilder<Event>(
        onUpdate: onUpdate,
        queryType: QueryType.all,
        queryName: 'listAllEvents',
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          scrollDirection: Axis.vertical,
          itemCount: events.length,
          itemBuilder: (context, i) {
            return GestureDetector(
                onTap: () {
                  // events[i].delete(events[i].item);
                  Navigator.pushNamed(context, '/event-item',
                      arguments: {'event': events[i]});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('id: ${events[i].id}'),
                    Text('title: ${events[i].title}'),
                    // Text('description: ${items[i].description}'),
                    // Text('time: ${items[i].time}'),
                    // Text('duration: ${items[i].duration} seconds'),
                    // Text('Is Complete? ${items[i].isComplete}'),
                  ],
                ));
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ));
  }
}
