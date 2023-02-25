// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:calendar/components/text/paragraph.dart';
import 'package:flutter/material.dart';

class DrawerRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() onTap;
  final Color color;
  final Color? backgroundColor;

  const DrawerRow(
      {Key? key,
      required this.icon,
      required this.text,
      required this.onTap,
      this.color = const Color.fromRGBO(0, 69, 77, 1),
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = backgroundColor ?? Colors.transparent;
    final rippleColor = backgroundColor == null
        ? Colors.black.withOpacity(0.1)
        : backgroundColor!.withOpacity(0.1);

    return Container(
        color: _backgroundColor,
        child: InkWell(
            highlightColor: rippleColor,
            splashColor: rippleColor,
            onTap: onTap,
            child: Column(children: [
              // Container(height: 1, color: Colors.black.withOpacity(0.1)),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Paragraph(text, small: true, color: color),
                      ])),
              Container(height: 1, color: Colors.black.withOpacity(0.1)),
            ])));
  }
}
