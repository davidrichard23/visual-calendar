import 'dart:developer';

import 'package:flutter/material.dart';

class Paragraph extends StatelessWidget {
  final String text;
  final bool small;
  final bool dense;
  final bool center;
  final Color? color;
  final bool bold;

  const Paragraph(
    this.text, {
    Key? key,
    this.small = false,
    this.dense = false,
    this.center = false,
    this.color = const Color.fromRGBO(0, 69, 77, 1),
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: center == true ? TextAlign.center : TextAlign.left,
        style: TextStyle(
            fontSize: small == true ? 12 : 16,
            color: color,
            letterSpacing: dense ? null : 1.5,
            wordSpacing: dense ? null : 1,
            height: dense ? null : 1.5,
            fontWeight: bold
                ? FontWeight.w900
                : dense
                    ? FontWeight.normal
                    : FontWeight.w600));
  }
}
