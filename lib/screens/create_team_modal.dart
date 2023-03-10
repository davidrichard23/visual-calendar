import 'dart:developer';

import 'package:calendar/components/token_input.dart';
import 'package:calendar/models/team_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/login/create_team.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class CreateTeamModal extends StatefulWidget {
  final id = ObjectId();

  CreateTeamModal({Key? key}) : super(key: key);

  @override
  State<CreateTeamModal> createState() => _CreateTeamModalState();
}

class _CreateTeamModalState extends State<CreateTeamModal> {
  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    final theme = Theme.of(context);

    handleCreateTeam(String dependentName) async {
      try {
        var team = TeamModel.create(
            realmManager.realm!,
            Team(
                ObjectId(),
                ObjectId.fromHexString(currentUser!.id),
                '', // teamname is no longer required
                dependentName));

        await Future.delayed(const Duration(milliseconds: 1000), () async {
          appState.setActiveTeam(realmManager.realm!, team!);
          await realmManager.waitForTeamPermissionsUpdate();
          appState.init(realmManager.realm);

          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (err) {
        rethrow;
      }
    }

    return Scaffold(
        appBar: AppBar(
          foregroundColor: const Color.fromRGBO(0, 69, 77, 1),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          // shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        backgroundColor: theme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreateTeam(onSubmit: handleCreateTeam, inverseColor: true),
            ],
          ),
        ));
  }
}
