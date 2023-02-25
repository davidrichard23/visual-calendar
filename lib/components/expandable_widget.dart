import 'package:flutter/material.dart';

class ExpandedableWidget extends StatefulWidget {
  final Widget child;
  final bool expand;
  final double axisAlignment;

  const ExpandedableWidget(
      {Key? key,
      this.expand = false,
      required this.child,
      this.axisAlignment = 0.0})
      : super(key: key);

  @override
  State<ExpandedableWidget> createState() => _ExpandedableWidgetState();
}

class _ExpandedableWidgetState extends State<ExpandedableWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? expandController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController!,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController?.forward();
    } else {
      expandController?.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: widget.axisAlignment,
        sizeFactor: animation!,
        child: widget.child);
  }
}
