import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/main.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({Key? key}) : super(key: key);

  @override
  State<TemplatesScreen> createState() => TemplatesScreenState();
}

class TemplatesScreenState extends State<TemplatesScreen> {
  List<EventModel> events = [];

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    void onUpdate<T extends RealmObject>(RealmResults<T> newEvents) {
      setState(() {
        events = newEvents
            .map((e) => EventModel(realmManager.realm!, e as Event))
            .toList();
      });
    }

    var queryName = 'listTemplates-${appState.activeTeam!.id}';
    var queryString = "teamId == \$0 AND isTemplate == true";
    var queryArgs = [appState.activeTeam!.id];

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Templates',
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          ),
          foregroundColor: const Color.fromRGBO(17, 182, 141, 1),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
        ),
        body: Builder(builder: ((context) {
          return RealmQueryBuilder<Event>(
              onUpdate: onUpdate,
              queryName: queryName,
              queryString: queryString,
              queryArgs: queryArgs,
              queryType: QueryType.queryString,
              child: Builder(builder: ((context) {
                return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      final event = events[i];
                      return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/create-event',
                              arguments: CreateEditScreenArgs(
                                  templateEvent: event,
                                  initalStartDate: DateTime.now())),
                          child: PrimaryCard(
                              child:
                                  Column(children: [Paragraph(event.title)])));
                    });
              })));
        })));
  }
}
