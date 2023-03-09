import 'dart:async';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class Init extends HookWidget {
  const Init({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AppServices>(context, listen: true).currentUser;
    final app = Provider.of<AppServices>(context);
    final appState = Provider.of<AppState>(context, listen: true);

    useEffect(() {
      if (!app.didInit || !appState.didInit) return;

      Future.delayed(Duration.zero, () {
        if (currentUser == null || appState.activeTeam == null) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });

      return;
    }, [app.didInit, appState.didInit]);

    return Container();
  }
}
