import 'dart:developer';

import 'package:calendar/components/token_input.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class JoinTeam extends StatefulWidget {
  final id = ObjectId();

  JoinTeam({Key? key}) : super(key: key);

  @override
  State<JoinTeam> createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    final theme = Theme.of(context);

    handleJoinTeam(String token) async {
      try {
        await currentUser!.functions.call('joinTeam', [token.toLowerCase()]);

        await realmManager.waitForTeamPermissionsUpdate();
        appState.setActiveTeam(realmManager.realm!, appState.allTeams[0]);

        Navigator.pop(context);
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
              TokenInput(onSubmit: handleJoinTeam),
            ],
          ),
        ));
  }
}
