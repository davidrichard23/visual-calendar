import 'dart:developer';

import 'package:flutter/material.dart';

class StyledTextButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;
  Color? color;

  StyledTextButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final colorr = color ?? Colors.black87;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(colorr.withOpacity(0.3)),
        foregroundColor: MaterialStateProperty.all(colorr),
        textStyle: MaterialStateProperty.all(
            TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
      ),
      child: child,
    );
  }
}
