import 'package:flutter/material.dart';

class H2 extends StatelessWidget {
  final String text;
  const H2(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color.fromRGBO(0, 69, 77, 1)));
  }
}
