import 'dart:async';
import 'dart:developer';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/models/team_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/login/create_team.dart';
import 'package:calendar/screens/login/email_password.dart';
import 'package:calendar/screens/login/scenario_selection.dart';
import 'package:calendar/screens/login/invite_token.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();

  LoginType? loginType;
  String? error;

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

        Navigator.pushReplacementNamed(context, '/home');
      } catch (err) {
        rethrow;
      }
    }

    void loginAnon() async {
      if (currentUser != null) return;

      try {
        await app.logInAnon();
      } catch (err) {
        rethrow;
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
          appState.setActiveTeam(realmManager.realm!, team!);
          await realmManager.waitForTeamPermissionsUpdate();

          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (err) {
        rethrow;
      }
    }

    joinTeam(String token) async {
      try {
        await currentUser!.functions.call('joinTeam', [token.toLowerCase()]);

        await realmManager.waitForTeamPermissionsUpdate();

        Navigator.pushReplacementNamed(context, '/home');
      } catch (err) {
        rethrow;
      }
    }

    setLoginType(LoginType type, {bool noAnim = false}) {
      setState(() {
        loginType = type;
      });
      if (noAnim) {
        _pageController.jumpToPage(_pageController.page!.toInt() + 1);
      } else {
        _pageController.nextPage(
            duration:
                noAnim ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      try {
        if (type == LoginType.setupDependent) loginAnon();
      } on AppException catch (err) {
        setState((() => error = err.message));
      }
    }

    if (loginType != LoginType.setupDependent &&
        currentUser?.provider == AuthProviderType.anonymous) {
      Timer(const Duration(milliseconds: 100),
          () => setLoginType(LoginType.setupDependent, noAnim: true));
    }

    return Scaffold(
        backgroundColor: theme.primaryColor,
        body: Builder(builder: ((context) {
          return SafeArea(
            bottom: false,
            child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  // Error
                  if (error != null)
                    MaxWidth(
                        maxWidth: maxWidth,
                        child: Text(
                          'Error: ${error!}',
                          style: const TextStyle(color: Colors.red),
                        )),

                  // Scenario
                  ScenarioSelection(setLoginType: setLoginType),

                  // Dependent
                  if (loginType == LoginType.setupDependent)
                    InviteToken(
                        hideBackButton: true,
                        pageController: _pageController,
                        onSubmit: joinTeam),

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
                          onSubmit: joinTeam, pageController: _pageController),

                  // Login
                  if (loginType == LoginType.login)
                    EmailPassword(
                        pageController: _pageController,
                        onSubmit: login,
                        submitText: 'Login')
                ]),
          );
        })));
  }
}
