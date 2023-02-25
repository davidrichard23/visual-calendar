// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';

// import 'package:calendar/components/create_event_task.dart';
// import 'package:calendar/components/lock_screen.dart';
// import 'package:calendar/models/event_model.dart';
// import 'package:calendar/models/event_task_model.dart';
// import 'package:calendar/realm/schemas.dart';
// import 'package:calendar/screens/event_screen.dart';
// import 'package:calendar/screens/event_task_screen.dart';
import 'package:calendar/components/global_error_display.dart';
import 'package:calendar/screens/create_edit_event/create_edit_task.dart';
import 'package:calendar/models/event_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/screens/daily/daily_screen.dart';
import 'package:calendar/screens/event_screen.dart';
import 'package:calendar/screens/home_screen.dart';
// import 'package:calendar/screens/home.dart';
import 'package:calendar/screens/init.dart';
import 'package:calendar/screens/join_team.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:realm/realm.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sheet/route.dart';
import 'dart:convert';
import './realm/app_services.dart';
import './realm/init_realm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  final realmConfig =
      json.decode(await rootBundle.loadString('assets/config/realm.json'));
  String appId = realmConfig['appId'];
  Uri baseUrl = Uri.parse(realmConfig['baseUrl']);

  return await SentryFlutter.init((options) {
    options.dsn =
        'https://ba6cd047cbc74373bdd4f9a1f09ca3fd@o4504715445141504.ingest.sentry.io/4504715452416000';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
  },
      appRunner: () => runApp(MultiProvider(providers: [
            ChangeNotifierProvider<AppServices>(
                create: (_) => AppServices(appId, baseUrl)),
            ChangeNotifierProxyProvider<AppServices, RealmManager?>(
                create: (context) => RealmManager(),
                update: (context, app, prevRealmManager) {
                  prevRealmManager?.close();
                  var realmManager = RealmManager();
                  if (app.currentUser != null) {
                    realmManager.init(app.currentUser!);
                    return realmManager;
                  }
                  return realmManager;
                }),
            // ),
            ChangeNotifierProxyProvider<RealmManager, AppState>(
                create: (context) => AppState(),
                update: (context, realmManager, appState) {
                  if (realmManager.realm == null) return AppState();
                  var state = AppState();
                  state.init(realmManager.realm!);
                  return state;
                })
          ], child: App())));
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final LocalStorage _appStorage = LocalStorage('app');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState?>(context, listen: true);

    // if (currentUser != null && !realmManager.isSynced) return Container();
    // final app = Provider.of<AppServices>(context);

    // if (currentUser != null) {
    //   // log('logout');
    //   realmManager.realm?.close();
    //   _appStorage.deleteItem('active-team-id');
    //   app.logOutUser();

    //   log('Error: Client reset - deleting realm...');
    //   // for some reason we need a small delay before deleting realm
    //   Timer(const Duration(milliseconds: 500), () {
    //     Realm.deleteRealm(realmManager.realm!.config.path);
    //     log('deleted');
    //   });
    // }

    // if (realm == null || appState == null) {
    //   return Container();
    // }

    // if (appState.allProfiles == null) {
    //   return Container();
    // }

    // if (!appState.allProfiles!.isNotEmpty) {
    //   ProfileModel.create(
    //       realm, Profile(ObjectId(), currentUser.id, 'Caregiver Name', true));
    //   return Container();
    // }
    // if (appState.activeProfile == null) {
    //   Timer(const Duration(milliseconds: 10), () {
    //     appState.setActiveProfile(appState.allProfiles![0]);
    //   });
    //   return Container();
    // }
    // return Container();

    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(59, 224, 184, 1),
          cardColor: Color.fromRGBO(0, 122, 137, 1),
          backgroundColor: Color.fromARGB(255, 225, 235, 237)),

      // backgroundColor: Colors.white),
      // initialRoute: '/',
      navigatorKey: navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return GlobalErrorDisplay(context: context, child: child);
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => Init());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          // case '/home':
          //   return MaterialExtendedPageRoute(
          //       builder: (context) => HomeScreen());
          case '/home':
            return MaterialExtendedPageRoute(
                builder: (context) => DailyScreen());
          case '/join-team':
            return CupertinoSheetRoute<void>(
                builder: (BuildContext newContext) => JoinTeam());
          case '/create-event':
            {
              final args = settings.arguments;
              final formattedArgs = args == null
                  ? CreateEditScreenArgs()
                  : args as CreateEditScreenArgs;

              return MaterialExtendedPageRoute(
                  builder: (BuildContext newContext) => CreateEditEvent(
                        existingEvent: formattedArgs.existingEvent,
                        initalStartDate: formattedArgs.initalStartDate,
                        initalDuration: formattedArgs.initalDuration,
                      ));
            }
          case '/create-edit-event-task':
            {
              final args = settings.arguments;
              final formattedArgs = args as CreateEditTaskScreenArgs;

              return CupertinoSheetRoute<void>(
                  builder: (BuildContext newContext) => CreateEditTask(
                        existingTask: formattedArgs.existingTask,
                        pendingImage: formattedArgs.pendingImage,
                        stageAddTask: formattedArgs.stageAddTask,
                        stageUpdateTask: formattedArgs.stageUpdateTask,
                        stageAddTaskImage: formattedArgs.stageAddTaskImage,
                        removeTaskImage: formattedArgs.removeTaskImage,
                        eventId: formattedArgs.eventId,
                      ));
            }
          case '/event':
            {
              final args = settings.arguments;
              final formattedArgs = args as EventScreenArgs;

              return MaterialExtendedPageRoute(
                  builder: (BuildContext newContext) => EventScreen(
                        eventId: formattedArgs.eventId,
                      ));
            }
        }
      },
    );
  }
  // '/home': (context) => HomeScreen(),
  // '/daily': (context) => DailyScreen(),
  // '/login': (context) => Login(),
  // '/join-team': (context) => JoinTeam(),
  // '/create-event': (context) {
  //   final args = ModalRoute.of(context)!.settings.arguments;
  //   final formattedArgs = args == null
  //       ? CreateEditScreenArgs()
  //       : args as CreateEditScreenArgs;

  //   return CupertinoPageRoute(builder: (_) => CreateEditEvent(
  //     existingEvent: formattedArgs.existingEvent,
  //     initalStartDate: formattedArgs.initalStartDate,
  //     initalDuration: formattedArgs.initalDuration,
  //   );
  // },
  // '/create-edit-event-task': (context) {
  //   final args = Map<String, Object>.from(
  //           ModalRoute.of(context)!.settings.arguments as Map)
  //       .values;

  //   return CreateEventTask(
  //     stageAddTask: args.first as Function(EventTask),
  //     eventId: args.elementAt(2) as String,
  //     order: args.elementAt(3) as int,
  //   );
  // },
  // '/event-item': (context) {
  //   final args = Map<String, Object>.from(
  //           ModalRoute.of(context)!.settings.arguments as Map)
  //       .values;

  //   return EventScreen(
  //     eventId: args.first as ObjectId,
  //   );
  // },
  // '/event-item-tasks': (context) {
  //   final args = Map<String, Object>.from(
  //           ModalRoute.of(context)!.settings.arguments as Map)
  //       .values;

  //   return EventTaskScreen(
  //     event: args.first as EventModel,
  //   );
  // },
  // }),
  // appState.isShowingLockScreen
  //     ? LockScreen((isValid) {
  //         if (isValid) appState.unlockCaregiver();
  //       })
  //     : Container()
  // ]));
  // }
}

class CreateEditScreenArgs {
  final EventModel? existingEvent;
  final DateTime? initalStartDate;
  final int? initalDuration;

  CreateEditScreenArgs(
      {this.existingEvent, this.initalStartDate, this.initalDuration});
}

class CreateEditTaskScreenArgs {
  final EventTask? existingTask;
  final UploadImageData? pendingImage;
  final Function(EventTask) stageAddTask;
  final Function(EventTask) stageUpdateTask;
  final Function(UploadImageData) stageAddTaskImage;
  final Function(ObjectId) removeTaskImage;
  final String eventId;

  CreateEditTaskScreenArgs(
      {this.existingTask,
      this.pendingImage,
      required this.stageAddTask,
      required this.stageUpdateTask,
      required this.stageAddTaskImage,
      required this.removeTaskImage,
      required this.eventId});
}

class EventScreenArgs {
  final ObjectId eventId;

  EventScreenArgs({required this.eventId});
}
