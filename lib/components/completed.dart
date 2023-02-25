import 'dart:developer' as a;
import 'dart:math';

import 'package:calendar/components/confetti.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class Completed extends StatelessWidget {
  final ConfettiController confettiController;
  final bool isVisible;
  const Completed(this.confettiController, this.isVisible, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Stack(children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: theme.backgroundColor,
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                        Text(
                          '🎉',
                          style: TextStyle(fontSize: 72),
                        ),
                        H1('You did it!'),
                      ]))),
              Positioned(
                  top: -200,
                  left: MediaQuery.of(context).size.width / 2,
                  child: Confetti(confettiController, pi / 2 + 0.4)),
              Positioned(
                top: -200,
                left: MediaQuery.of(context).size.width / 2,
                child: Confetti(confettiController, pi / 2),
              ),
              Positioned(
                top: -200,
                left: MediaQuery.of(context).size.width / 2,
                child: Confetti(confettiController, pi / 2 - 0.4),
              )
            ])));
  }
}
