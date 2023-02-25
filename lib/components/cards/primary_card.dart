import 'package:flutter/material.dart';

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const PrimaryCard(
      {Key? key,
      required this.child,
      this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      this.padding = const EdgeInsets.all(16),
      this.boxShadow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        margin: margin,
        padding: padding,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: boxShadow,
        ),
        child: child);
  }
}
