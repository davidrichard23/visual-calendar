import 'package:calendar/models/team_model.dart';
import 'package:flutter/material.dart';

class TeamSelectionRow extends StatelessWidget {
  final TeamModel team;
  final Function(TeamModel) onTap;
  final bool isActive;

  const TeamSelectionRow(
      {Key? key,
      required this.onTap,
      required this.team,
      this.isActive = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onTap(team),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              color: Colors.white,
              border: isActive
                  ? Border.all(
                      color: const Color.fromRGBO(0, 69, 77, 1),
                      width: 4,
                      strokeAlign: BorderSide.strokeAlignOutside)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ]),
          child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.people_alt_outlined,
                        size: 24.0,
                        color: const Color.fromRGBO(0, 69, 77, 1)
                            .withOpacity(isActive ? 1 : 0.6))),
                Text(
                  team.title,
                  style: TextStyle(
                      color: const Color.fromRGBO(0, 69, 77, 1)
                          .withOpacity(isActive ? 1 : 0.6),
                      fontWeight: FontWeight.bold),
                )
              ]),
        ));
  }
}
