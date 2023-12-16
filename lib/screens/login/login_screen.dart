// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/buttons/styled_text_button.dart';
import 'package:calendar/models/team_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/login/components/check_email.dart';
import 'package:calendar/screens/login/components/create_team.dart';
import 'package:calendar/screens/login/components/email_password.dart';
import 'package:calendar/screens/login/components/scenario_selection.dart';
import 'package:calendar/screens/login/components/invite_token.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

const double maxWidth = 500;

enum LoginType {
  login,
  createTeam,
  joinTeam,
  setupDependent,
}

enum ResetPasswordPhase {
  none,
  sendEmail,
  checkEmail,
  resetPassword,
}

class LoginScreen extends StatefulWidget {
  final String? resetToken;
  final String? resetTokenId;

  const LoginScreen({Key? key, this.resetToken, this.resetTokenId})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();

  LoginType? loginType;
  ResetPasswordPhase resetPasswordPhase = ResetPasswordPhase.none;
  String? error;

  @override
  void initState() {
    super.initState();

    if (widget.resetToken != null &&
        widget.resetTokenId != null &&
        resetPasswordPhase != ResetPasswordPhase.resetPassword) {
      setState(() {
        loginType = LoginType.login;
        resetPasswordPhase = ResetPasswordPhase.resetPassword;
      });
      Timer(const Duration(milliseconds: 100), () {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final realmManager = Provider.of<RealmManager>(context, listen: true);
    final app = Provider.of<AppServices>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);
    final currentUser = app.currentUser;

    createAccount(String email, String password) async {
      if (currentUser != null) return;

      try {
        await app.registerUserEmailPw(email, password);
      } catch (err) {
        rethrow;
      }
    }

    void login(String email, String password) async {
      if (currentUser != null) return;

      try {
        await app.logInUserEmailPw(email, password);

        // need a small delay for realmmanager to init
        await Future.delayed(const Duration(milliseconds: 500), () async {
          final realmManager =
              Provider.of<RealmManager>(context, listen: false);

          await appState.init(realmManager.realm);

          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (err) {
        rethrow;
      }
    }

    Future<void> loginAnon() async {
      if (currentUser != null) return;

      try {
        await app.logInAnon();
      } catch (err) {
        rethrow;
      }
    }

    Future<void> handleSendPasswordResetEmail(String email, String _) async {
      try {
        await app.sendPasswordResetEmail(email);
        setState(() {
          resetPasswordPhase = ResetPasswordPhase.checkEmail;
          error = null;
        });
      } catch (err) {
        setState(() {
          error =
              'Something went wrong. Please make sure you\'re connected to the internet and entered a valid email';
        });
      }
    }

    Future<void> handleSetNewPassword(String _, String password) async {
      if (widget.resetToken == null || widget.resetTokenId == null) {
        setState(() {
          error = 'Something went wrong. Please try again later';
        });
        return;
      }

      try {
        await app.resetPassword(
            password, widget.resetToken!, widget.resetTokenId!);
        setState(() {
          resetPasswordPhase = ResetPasswordPhase.none;
          error = null;
        });
      } catch (err) {
        setState(() {
          error =
              'Something went wrong. Your reset token may have expired. Please try again.';
        });
      }
    }

    createTeam(String dependentName) async {
      try {
        var team = TeamModel.create(
            realmManager.realm!,
            Team(
                ObjectId(),
                ObjectId.fromHexString(currentUser!.id),
                '', // teamname is no longer required
                dependentName));

        await Future.delayed(const Duration(milliseconds: 1000), () async {
          final realmManager =
              Provider.of<RealmManager>(context, listen: false);
          await realmManager.waitForTeamPermissionsUpdate();
          await appState.init(realmManager.realm);

          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (err) {
        rethrow;
      }
    }

    joinTeam(String token) async {
      try {
        await app.currentUser!.functions
            .call('joinTeam', [token.toLowerCase()]);

        final realmManager = Provider.of<RealmManager>(context, listen: false);

        await realmManager.waitForTeamPermissionsUpdate();
        await appState.init(realmManager.realm);

        Navigator.pushReplacementNamed(context, '/home');
      } catch (err) {
        rethrow;
      }
    }

    setupDependent(String token) async {
      if (currentUser == null) await loginAnon();
      await joinTeam(token);
    }

    setLoginType(LoginType type, {bool noAnim = false}) {
      setState(() {
        loginType = type;
        resetPasswordPhase = ResetPasswordPhase.none;
      });
      if (noAnim) {
        _pageController.jumpToPage(_pageController.page!.toInt() + 1);
      } else {
        _pageController.nextPage(
            duration:
                noAnim ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      // prevent anon accounts from being caregivers
      if ((type == LoginType.createTeam || type == LoginType.joinTeam) &&
          currentUser != null &&
          currentUser.provider == AuthProviderType.anonymous) {
        app.logOutUser();
      }
    }

    return Scaffold(
        backgroundColor: theme.primaryColor,
        body: Builder(builder: ((context) {
          return SafeArea(
              bottom: false,
              child: Column(children: [
                // Error
                if (error != null)
                  MaxWidth(
                      maxWidth: maxWidth,
                      child: Text(
                        'Error: ${error!}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )),
                Expanded(
                    child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [
                      // Scenario
                      ScenarioSelection(setLoginType: setLoginType),

                      // Dependent
                      if (loginType == LoginType.setupDependent)
                        InviteToken(
                            pageController: _pageController,
                            onSubmit: setupDependent),

                      // Create Team
                      if (loginType == LoginType.createTeam)
                        if (currentUser == null)
                          EmailPassword(
                              pageController: _pageController,
                              onSubmit: createAccount,
                              submitText: 'Create Account')
                        else
                          CreateTeam(
                              onSubmit: createTeam,
                              pageController: _pageController),

                      // Join Team
                      if (loginType == LoginType.joinTeam)
                        if (currentUser == null)
                          EmailPassword(
                              pageController: _pageController,
                              onSubmit: createAccount,
                              submitText: 'Create Account')
                        else
                          InviteToken(
                              onSubmit: joinTeam,
                              pageController: _pageController),

                      // Login
                      if (loginType == LoginType.login)
                        Column(children: [
                          Builder(builder: (context) {
                            if (resetPasswordPhase == ResetPasswordPhase.none) {
                              return EmailPassword(
                                  pageController: _pageController,
                                  onSubmit: login,
                                  submitText: 'Login');
                            } else if (resetPasswordPhase ==
                                ResetPasswordPhase.sendEmail) {
                              return EmailPassword(
                                  pageController: _pageController,
                                  onSubmit: handleSendPasswordResetEmail,
                                  hidePassword: true,
                                  submitText: 'Reset Password');
                            } else if (resetPasswordPhase ==
                                ResetPasswordPhase.checkEmail) {
                              return CheckEmail(
                                  pageController: _pageController);
                            } else if (resetPasswordPhase ==
                                ResetPasswordPhase.resetPassword) {
                              return EmailPassword(
                                  pageController: _pageController,
                                  onSubmit: handleSetNewPassword,
                                  hideEmail: true,
                                  submitText: 'Set New Password');
                            }

                            return Container();
                          }),
                          if (resetPasswordPhase == ResetPasswordPhase.none)
                            StyledTextButton(
                                onPressed: () {
                                  setState(() {
                                    resetPasswordPhase =
                                        ResetPasswordPhase.sendEmail;
                                  });
                                },
                                child: const Text('Forgot Password?')),
                        ]),
                    ])),
              ]));
        })));
  }
}
