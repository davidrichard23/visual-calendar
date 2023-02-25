import 'dart:developer';

import 'package:calendar/main.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final DateTime selectedDateTime;
  final Function(String) changeViewType;

  const DailyAppBar(
      {Key? key, required this.selectedDateTime, required this.changeViewType})
      : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<DailyAppBar> createState() => DailyAppBarState();
}

class DailyAppBarState extends State<DailyAppBar> {
  String selectedView = 'manage';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    return AppBar(
      // title: const Text('Daily Schedule'),
      backgroundColor: Colors.white,
      foregroundColor: theme.primaryColor,
      elevation: 0,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            height: 1,
          )),
      title: CupertinoSlidingSegmentedControl(
        backgroundColor: theme.backgroundColor,
        thumbColor: theme.primaryColor,
        groupValue: selectedView,
        onValueChanged: (value) {
          if (value != null) {
            widget.changeViewType(value);
            setState(() => selectedView = value);
          }
        },
        children: const {
          'manage': Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Manage',
              style:
                  TextStyle(fontSize: 14, color: Color.fromRGBO(0, 69, 77, 1)),
            ),
          ),
          'view': Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'View',
              style:
                  TextStyle(fontSize: 14, color: Color.fromRGBO(0, 69, 77, 1)),
            ),
          )
        },
      ),
      actions: appState.teamUserType == 'caregiver'
          ? [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 35.0,
                ),
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                onPressed: () => Navigator.pushNamed(context, '/create-event',
                    arguments: CreateEditScreenArgs(
                        initalStartDate: widget.selectedDateTime)),
              )
            ]
          : [],
    );
  }
}
