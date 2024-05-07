import 'dart:async';
import 'dart:isolate';

import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalErrorDisplay extends StatefulWidget {
  final BuildContext context;

  const GlobalErrorDisplay({Key? key, required this.context}) : super(key: key);

  @override
  State<GlobalErrorDisplay> createState() => _GlobalErrorDisplayState();
}

class _GlobalErrorDisplayState extends State<GlobalErrorDisplay> {
  String? error;

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => error = details.summary.toString());
      });
      // myErrorsHandler.onErrorDetails(details);
    };
    PlatformDispatcher.instance.onError = (e, stack) {
      // myErrorsHandler.onError(error, stack);
      Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => error = e.toString());
      });
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      if (mounted) setState(() => error = errorAndStacktrace.toString());
    }).sendPort);

    if (error != null) {
      return Material(
          color: const Color.fromARGB(255, 255, 117, 107),
          child: SafeArea(
              bottom: false,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 8),
                            child: Paragraph(
                              'Error: ${error!}',
                              color: Colors.white,
                              small: true,
                            ))),
                    IconButton(
                        onPressed: () => setState(() => error = null),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.white, size: 25))
                  ])));
    }

    return Container();
  }
}
