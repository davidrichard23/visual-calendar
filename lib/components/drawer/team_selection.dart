import 'package:calendar/components/drawer/team_selection_row.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/team_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/extensions/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamSelection extends StatefulWidget {
  const TeamSelection({Key? key}) : super(key: key);

  @override
  State<TeamSelection> createState() => TeamSelectionState();
}

class TeamSelectionState extends State<TeamSelection> {
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    final realmManager = Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    handleJoinTeam() {
      Navigator.pushNamed(context, '/join-team');
    }

    handleChangeActiveTeam(TeamModel team) {
      appState.setActiveTeam(realmManager.realm!, team);
    }

    return GestureDetector(
        onTap: () => setState(() => isOpen = !isOpen),
        child: Stack(children: [
          Transform.translate(
              offset: const Offset(0, 25),
              child: ExpandedableWidget(
                  expand: isOpen,
                  axisAlignment: 1.0,
                  child: Column(children: [
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 32, bottom: 8, left: 16, right: 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(25)),
                        ),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: const H1('Your Teams')),
                            ...appState.allTeams
                                .map((team) => TeamSelectionRow(
                                    onTap: handleChangeActiveTeam,
                                    team: team,
                                    isActive:
                                        team.id == appState.activeTeam?.id))
                                .toList(),
                            const SizedBox(height: 16),
                            GestureDetector(
                                onTap: handleJoinTeam,
                                child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: theme.primaryColor,
                                    ),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin:
                                                const EdgeInsets.only(right: 4),
                                            child: const Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                                size: 24.0,
                                                color: Colors.white)),
                                        const Text(
                                          'Join New Team',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )))
                          ],
                        )),
                    const SizedBox(height: 25),
                  ]))),
          Stack(clipBehavior: Clip.none, children: [
            Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ])),
            Positioned(
                top: -5,
                child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      radius: 30,
                      child: Text(
                          appState.activeTeam?.dependentName.getInitials() ??
                              ''),
                    ))),
            Positioned(
              top: 0,
              bottom: 0,
              left: 68,
              right: 0,
              child: Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Paragraph(
                        '${appState.activeTeam?.dependentName ?? ''}\'s Team')
                  ]),
            ),
          ]),
          // const SizedBox(height: 16),
        ]));
  }
}
