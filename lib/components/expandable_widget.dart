import 'package:flutter/material.dart';

class ExpandedableWidget extends StatefulWidget {
  final Widget child;
  final bool expand;
  final double axisAlignment;
  final int miliseconds;
  final Curve curve;

  const ExpandedableWidget(
      {Key? key,
      this.expand = false,
      required this.child,
      this.axisAlignment = 0.0,
      this.miliseconds = 300,
      this.curve = Curves.fastOutSlowIn})
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
        vsync: this, duration: Duration(milliseconds: widget.miliseconds));
    animation = CurvedAnimation(
      parent: expandController!,
      curve: widget.curve,
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
