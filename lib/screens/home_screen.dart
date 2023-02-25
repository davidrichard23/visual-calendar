import 'dart:developer';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/drawer/drawer.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/models/team_invite_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  List<EventModel> events = [];
  TeamInviteModel? caregiverInvite;
  TeamInviteModel? dependentInvite;

  setSelectedDate(date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    final appState = Provider.of<AppState>(context, listen: true);
    final app = Provider.of<AppServices>(context);
    final theme = Theme.of(context);

    final teamUserType = appState.teamUserType;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
        ),
        drawer: teamUserType == 'caregiver' ? const DrawerComponent() : null,
        body: Column(children: [
          const SizedBox(height: 8),
          PrimaryButton(
              onPressed: () {
                app.logOutUser();
                // app.deleteUser(realmManager.realm!);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout')),
          // PrimaryButton(
          //     onPressed: () {
          //       Navigator.pushNamed(context, '/create-event');
          //     },
          //     child: const Text('Add Event')),
          const SizedBox(height: 8),
          PrimaryButton(
              onPressed: () {
                Navigator.pushNamed(context, '/daily');
              },
              child: Text('List Events - $teamUserType')),

          if (caregiverInvite != null)
            Container(
                margin: const EdgeInsets.only(top: 16),
                child: SelectableText(
                    'Caregiver Invite Token: ${caregiverInvite!.token.toUpperCase()}')),
          const SizedBox(height: 8),
          if (teamUserType == 'caregiver')
            PrimaryButton(
                onPressed: () {
                  final invite = TeamInviteModel.create(
                      realmManager.realm!,
                      TeamInvite(
                          ObjectId(), appState.activeTeam!.id, 'caregiver'));
                  setState(() {
                    caregiverInvite = invite;
                  });
                },
                child: const Text('Generate Caregiver Invite')),

          if (dependentInvite != null)
            Container(
                margin: const EdgeInsets.only(top: 16),
                child: SelectableText(
                    'Dependent Invite Token: ${dependentInvite!.token.toUpperCase()}')),
          const SizedBox(height: 8),
          if (teamUserType == 'caregiver')
            PrimaryButton(
                onPressed: () {
                  final invite = TeamInviteModel.create(
                      realmManager.realm!,
                      TeamInvite(
                          ObjectId(), appState.activeTeam!.id, 'dependent'));
                  setState(() {
                    dependentInvite = invite;
                  });
                },
                child: const Text('Generate Dependent Invite')),
        ]));
  }
}
