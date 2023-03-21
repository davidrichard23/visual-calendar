import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

double pointSize = 25;

class ImageFocalPointSelectionScreen extends StatefulWidget {
  final File image;
  final double aspectRatio;
  final Function(File, FocalPoint) onSelectFocalPoint;

  const ImageFocalPointSelectionScreen(
      {Key? key,
      required this.image,
      required this.aspectRatio,
      required this.onSelectFocalPoint})
      : super(key: key);

  @override
  State<ImageFocalPointSelectionScreen> createState() =>
      ImageFocalPointSelectionScreenState();
}

class ImageFocalPointSelectionScreenState
    extends State<ImageFocalPointSelectionScreen> {
  final GlobalKey imageKey = GlobalKey();
  Point markerPoint = const Point(-100.0, -100.0);
  FocalPoint focalPoint = FocalPoint(0.0, 0.0);

  void handleSubmit() {
    widget.onSelectFocalPoint(widget.image, focalPoint);
    Navigator.pop(context);
  }

  void handleTapUp(TapUpDetails details) {
    setFocalPoint(details.localPosition);
  }

  void handleDragUpdate(DragUpdateDetails details) {
    setFocalPoint(details.localPosition);
  }

  void handleDragDown(DragDownDetails details) {
    setFocalPoint(details.localPosition);
  }

  void setFocalPoint(offset) {
    final RenderBox renderBox =
        imageKey.currentContext?.findRenderObject() as RenderBox;
    double x = offset.dx;
    double y = offset.dy;

    if (x < 0 + pointSize / 2) x = pointSize / 2;
    if (y < 0 + pointSize / 2) y = pointSize / 2;
    if (x > renderBox.size.width - pointSize / 2) {
      x = renderBox.size.width - pointSize / 2;
    }
    if (y > renderBox.size.height - pointSize / 2) {
      y = renderBox.size.height - pointSize / 2;
    }

    setState(() {
      markerPoint = Point<double>(x - pointSize / 2, y - pointSize / 2);
      focalPoint =
          FocalPoint(x / renderBox.size.width, y / renderBox.size.height);
    });
  }

  @override
  void initState() {
    super.initState();

    // set initial focal point to the center
    Timer(const Duration(milliseconds: 500), () {
      final RenderBox renderBox =
          imageKey.currentContext?.findRenderObject() as RenderBox;
      setFocalPoint(
          Offset(renderBox.size.width / 2, renderBox.size.height / 2));

      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final app = Provider.of<AppServices>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: ((context) {
          return SafeArea(
              child: SizedBox(
                  width: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: const [
                              H1('Select a focal point'),
                              SizedBox(height: 8),
                              Paragraph(
                                  'In some parts of the app, we only display a portion of the image, in these situations, we want to make sure we show the most important area of the image. Choose this area on the image below.',
                                  small: true),
                            ])),
                        Flexible(
                            child: Stack(children: [
                          GestureDetector(
                              onTapUp: handleTapUp,
                              onVerticalDragDown: handleDragDown,
                              onHorizontalDragDown: handleDragDown,
                              onVerticalDragUpdate: handleDragUpdate,
                              onHorizontalDragUpdate: handleDragUpdate,
                              child: Image.file(widget.image, key: imageKey)),
                          Positioned(
                              top: markerPoint.y as double,
                              left: markerPoint.x as double,
                              child: IgnorePointer(
                                  child: Container(
                                      width: pointSize,
                                      height: pointSize,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.black, width: 1)),
                                      child: Center(
                                          child: Container(
                                              width: pointSize - 6,
                                              height: pointSize - 6,
                                              decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle))))))
                        ])),
                        const SizedBox(height: 8),
                        SizedBox(
                            width: 150,
                            child: PrimaryButton(
                                small: true,
                                onPressed: handleSubmit,
                                child: const Text('Submit')))
                      ])));
        })));
  }
}
