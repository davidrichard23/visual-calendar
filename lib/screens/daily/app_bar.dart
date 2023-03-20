import 'dart:developer';

import 'package:calendar/main.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/responsive_layout_helper.dart';
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
    final now = DateTime.now();
    final currentTime = DateTime(
        widget.selectedDateTime.year,
        widget.selectedDateTime.month,
        widget.selectedDateTime.day,
        now.hour,
        now.minute);

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
      title: ResponsiveLayoutHelper.isMobile(context) &&
              appState.teamUserType == 'caregiver'
          ? CupertinoSlidingSegmentedControl(
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Color.fromRGBO(0, 69, 77, 1)),
                  ),
                ),
                'view': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Dependent View',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: Color.fromRGBO(0, 69, 77, 1)),
                  ),
                )
              },
            )
          : const Text('Visual Calendar',
              style: TextStyle(color: Color.fromRGBO(0, 69, 77, 1))),
      actions: appState.teamUserType == 'caregiver'
          ? [
              PopupMenuButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 35.0,
                  color: theme.primaryColor,
                ),
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'new') {
                    Navigator.pushNamed(context, '/create-event',
                        arguments:
                            CreateEditScreenArgs(initalStartDate: currentTime));
                  } else {
                    Navigator.pushNamed(context, '/templates');
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                      value: 'new',
                      child: Row(children: const [
                        Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.create_outlined)),
                        Flexible(child: Text('Create New Event')),
                      ])),
                  PopupMenuItem(
                      value: 'template',
                      child: Row(children: const [
                        Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.copy)),
                        Flexible(child: Text('Create Event From A Template')),
                      ])),
                ],
              )
            ]
          : [],
    );
  }
}
