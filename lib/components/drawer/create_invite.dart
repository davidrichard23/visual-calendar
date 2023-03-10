import 'dart:async';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/team_invite_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

const inviteTypeDescriptions = {
  'caregiver':
      'A caregiver is someone who is able to create and edit events for this team\'s dependent. This person will need to create an account and use an invite token to join the team.',
  'dependent':
      'A dependent is someone who will be using the calendar to help structure their day. There can only be one dependent per team, but you can use multiple invites to setup multiple devices for them. A dependent does not need to sign up for an account.'
};

class CreateInvite extends StatefulWidget {
  final bool isOpen;

  const CreateInvite({Key? key, required this.isOpen}) : super(key: key);

  @override
  State<CreateInvite> createState() => CreateInviteState();
}

class CreateInviteState extends State<CreateInvite> {
  String selectedInviteType = 'caregiver';
  TeamInviteModel? newInvite;

  @override
  Widget build(BuildContext context) {
    final realmManager = Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    handleCreate() {
      final invite = TeamInviteModel.create(realmManager.realm!,
          TeamInvite(ObjectId(), appState.activeTeam!.id, selectedInviteType));

      setState(() {
        newInvite = invite;
      });

      Clipboard.setData(ClipboardData(text: invite!.token.toUpperCase()))
          .then((_) {
        Fluttertoast.showToast(
            msg: "Copied To Clipboard",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }

    return ExpandedableWidget(
        expand: widget.isOpen,
        // axisAlignment: -1,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CupertinoSlidingSegmentedControl(
                      backgroundColor: theme.backgroundColor,
                      thumbColor: theme.primaryColor,
                      groupValue: selectedInviteType,
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedInviteType = value;
                            newInvite = null;
                          });
                        }
                      },
                      children: const {
                        'caregiver': Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Caregiver',
                            style:
                                TextStyle(color: Color.fromRGBO(0, 69, 77, 1)),
                          ),
                        ),
                        'dependent': Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Dependent',
                            style:
                                TextStyle(color: Color.fromRGBO(0, 69, 77, 1)),
                          ),
                        )
                      },
                    ),
                    const SizedBox(height: 16),
                    Paragraph(inviteTypeDescriptions[selectedInviteType]!,
                        small: true, dense: true),
                    if (newInvite != null) const SizedBox(height: 16),
                    if (newInvite != null)
                      H1(newInvite!.token.toUpperCase(), isSelectable: true),
                    const SizedBox(height: 16),
                    PrimaryButton(
                        small: true,
                        onPressed: handleCreate,
                        child: const Paragraph('Generate Invite', small: true)),
                  ],
                ))));
  }
}
