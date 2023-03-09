import 'package:flutter/material.dart';

class MaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MaxWidth({required this.maxWidth, required this.child, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth), child: child))
    ]);
  }
}
