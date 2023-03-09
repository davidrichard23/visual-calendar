import 'dart:developer';

import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/h2.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/screens/login/login_button.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/screens/login/login_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:realm/realm.dart';

class CreateTeam extends StatefulWidget {
  final Function(String) onSubmit;
  final PageController pageController;

  const CreateTeam(
      {Key? key, required this.onSubmit, required this.pageController})
      : super(key: key);

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String depententsName = '';
  String? error;
  bool isLoading = false;

  void handleSubmit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          error = null;
          isLoading = true;
        });
        await widget.onSubmit(depententsName);
        setState(() => isLoading = false);
      } on AppException catch (err) {
        setState(() {
          error = err.message;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: MaxWidth(
            maxWidth: maxWidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(
                onPressed: () {
                  if (isLoading) return;
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              // const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (error != null)
                          Text(
                            'Error: ${error!}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 16),
                        const H1(
                          'Create a Team',
                          large: true,
                        ),
                        const SizedBox(height: 24),
                        Form(
                            key: _formKey,
                            child: Column(children: [
                              //       Container(
                              //           margin: const EdgeInsets.symmetric(
                              //               horizontal: 16, vertical: 16),
                              //           child: Column(
                              //               crossAxisAlignment: CrossAxisAlignment.start,
                              //               children: const [
                              //                 H2('Team Name'),
                              //                 Paragraph(
                              //                   'Give your team a name. Your team can consist of just you, or any number of other people.',
                              //                   small: true,
                              //                 )
                              //               ])),
                              //       LoginTextFormField(
                              //         hintText: 'Team Name',
                              //         textInputAction: TextInputAction.next,
                              //         textCapitalization: TextCapitalization.words,
                              //         onSaved: (String? value) {
                              //           if (value == null) return;
                              //           teamName = value;
                              //         },
                              //         validator: (String? value) {
                              //           if (value == null ||
                              //               value.isEmpty ||
                              //               value.length < 2) {
                              //             return 'Please enter a Team Name';
                              //           }
                              //           return null;
                              //         },
                              //       ),
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        H2('Dependent\'s Name'),
                                        Paragraph(
                                          'A team is focused around a single dependent. It can consist of just you and your dependent, or multiple other caretakers.',
                                          small: true,
                                        )
                                      ])),
                              LoginTextFormField(
                                hintText: 'Dependent\'s Name',
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                // onSubmitted: (_) => handleSubmit, // cant get this to work
                                onSaved: (String? value) {
                                  if (value == null) return;
                                  depententsName = value;
                                },
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 2) {
                                    return 'Please enter a Dependent Name';
                                  }
                                  return null;
                                },
                              )
                            ])),
                        const SizedBox(height: 16),
                        LoginScreenButton(
                          text: 'Create Team',
                          icon: Icons.login_rounded,
                          onTap: handleSubmit,
                          isLoading: isLoading,
                        ),
                      ]))
            ])));
  }
}
