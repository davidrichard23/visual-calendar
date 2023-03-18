import 'dart:async';
import 'package:calendar/realm/init_realm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RealmSyncStatus extends StatefulWidget {
  final BuildContext context;

  const RealmSyncStatus({Key? key, required this.context}) : super(key: key);

  @override
  State<RealmSyncStatus> createState() => _RealmSyncStatusState();
}

class _RealmSyncStatusState extends State<RealmSyncStatus> {
  late Timer sessionStateTimer;
  late StreamSubscription connectionStreamListener;
  String? connectionAlert;
  String? sessionAlert;

  @override
  void initState() {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: false);
    if (realmManager.realm == null) return;

    final syncSession = realmManager.realm!.syncSession;

    // connection
    handleConnectionState(syncSession.connectionState.name);
    connectionStreamListener =
        syncSession.connectionStateChanges.listen((connectionStateChange) {
      // ConnectionState class seems to not be updated. ConnectionState.connected does not exist
      handleConnectionState(connectionStateChange.current.name);
    });

    // session
    sessionStateTimer =
        Timer.periodic(const Duration(seconds: 3), handleSessionState);

    super.initState();
  }

  @override
  void dispose() {
    connectionStreamListener.cancel();
    sessionStateTimer.cancel();
    super.dispose();
  }

  void handleConnectionState(String state) {
    if (state == 'connected') {
      if (connectionAlert != null) setState(() => connectionAlert = null);
    }
    if (state == 'disconnected') {
      if (connectionAlert == null) {
        setState(() {
          connectionAlert = 'You are disconnected from the internet.';
        });
      }
    }
  }

  void handleSessionState(Timer timer) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: false);

    if (realmManager.realm == null) return;
    if (realmManager.realm!.syncSession.state.name == 'active') {
      if (sessionAlert != null) setState(() => sessionAlert = null);
    }
    if (realmManager.realm!.syncSession.state.name == 'inactive') {
      if (sessionAlert == null) {
        setState(() {
          sessionAlert =
              'You are disconnected from the server. Please restart the app.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sessionAlert != null) {
      return Material(
          color: const Color.fromARGB(255, 255, 245, 106),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
                width: double.infinity,
                child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Text(
                      sessionAlert!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6), fontSize: 10),
                    ))),
          ));
    }
    // else if (connectionAlert != null) {
    //   return Material(
    //       color: const Color.fromARGB(255, 255, 245, 106),
    //       child: SafeArea(
    //         bottom: false,
    //         child: SizedBox(
    //             width: double.infinity,
    //             child: Padding(
    //                 padding:
    //                     const EdgeInsets.only(left: 16, right: 16, bottom: 8),
    //                 child: Text(
    //                   connectionAlert!,
    //                   textAlign: TextAlign.center,
    //                   style: TextStyle(
    //                       color: Colors.black.withOpacity(0.6), fontSize: 10),
    //                 ))),
    //       ));
    // }

    return Container();
  }
}
