import 'dart:async';

import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalErrorDisplay extends StatefulWidget {
  final Widget? child;
  final BuildContext context;

  const GlobalErrorDisplay(
      {Key? key, required this.child, required this.context})
      : super(key: key);

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
        setState(() => error = details.summary.toString());
      });
      // myErrorsHandler.onErrorDetails(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      // myErrorsHandler.onError(error, stack);
      Timer(const Duration(milliseconds: 100), () {
        setState(() => error = error.toString());
      });
      return true;
    };

    return Stack(children: [
      widget.child!,
      if (error != null)
        Container(
            color: const Color.fromARGB(255, 255, 117, 107),
            width: double.infinity,
            child: SafeArea(
                child: Material(
                    color: Colors.transparent,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Paragraph(
                            'Error: ${error!}',
                            color: Colors.white,
                            small: true,
                          )),
                          IconButton(
                              onPressed: () => setState(() => error = null),
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.white, size: 35))
                        ]))))
    ]);
  }
}
