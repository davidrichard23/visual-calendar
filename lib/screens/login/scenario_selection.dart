import 'dart:developer';

import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/screens/login/login_button.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class ScenarioSelection extends StatefulWidget {
  final Function(LoginType) setLoginType;

  const ScenarioSelection({Key? key, required this.setLoginType})
      : super(key: key);

  @override
  State<ScenarioSelection> createState() => _ScenarioSelectionState();
}

class _ScenarioSelectionState extends State<ScenarioSelection> {
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppServices>(context, listen: true);
    final currentUser = app.currentUser;

    return SingleChildScrollView(
        child: MaxWidth(
            maxWidth: maxWidth,
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const H1(
                        'Welcome',
                        large: true,
                      ),
                      const Paragraph(
                        'Lets Get Started. Select a scenario below.',
                        center: true,
                      ),
                      const SizedBox(height: 24),
                      LoginScreenButton(
                          icon: Icons.add_circle_outline,
                          onTap: () =>
                              widget.setLoginType(LoginType.createTeam),
                          text:
                              'I am caretaker and want to setup a calendar for my dependent.'),
                      LoginScreenButton(
                          icon: Icons.people_outline,
                          onTap: () => widget.setLoginType(LoginType.joinTeam),
                          text:
                              'I am caretaker and want to join a team already created for a dependent.'),
                      if (currentUser == null ||
                          currentUser.provider == AuthProviderType.anonymous)
                        LoginScreenButton(
                            icon: Icons.tablet_mac_outlined,
                            onTap: () =>
                                widget.setLoginType(LoginType.setupDependent),
                            text:
                                'I am caretaker and am setting up my dependent\'s device.'),
                      const SizedBox(height: 32),
                      TextButton(
                          style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(100, 195, 255, 239))),
                          onPressed: () => widget.setLoginType(LoginType.login),
                          child: const Paragraph('Login'))
                    ]))));
  }
}
