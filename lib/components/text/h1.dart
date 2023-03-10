import 'package:flutter/material.dart';

class H1 extends StatelessWidget {
  final String text;
  final Color? color;
  final bool? large;
  final bool? center;
  final bool isSelectable;
  const H1(this.text,
      {Key? key,
      this.large,
      this.center = false,
      this.color,
      this.isSelectable = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSelectable) {
      return SelectableText(text,
          textAlign: center == true ? TextAlign.center : TextAlign.left,
          style: TextStyle(
              fontSize: large == true ? 40 : 22,
              fontWeight: FontWeight.w900,
              color:
                  color != null ? color! : const Color.fromRGBO(0, 69, 77, 1)));
    }

    return Text(text,
        textAlign: center == true ? TextAlign.center : TextAlign.left,
        style: TextStyle(
            fontSize: large == true ? 40 : 22,
            fontWeight: FontWeight.w900,
            color:
                color != null ? color! : const Color.fromRGBO(0, 69, 77, 1)));
  }
}
