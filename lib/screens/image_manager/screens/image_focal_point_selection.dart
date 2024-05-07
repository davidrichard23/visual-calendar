import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/image_manager/screens/web_image_search.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';

double pointSize = 25;

class ImageFocalPointSelection extends StatefulWidget {
  final ImageData? existingImage;
  final File? localImage;
  final WebImage? webImage;
  final FocalPoint startingFocalPoint;
  final Function(FocalPoint) onSelectFocalPoint;

  const ImageFocalPointSelection(
      {Key? key,
      required this.existingImage,
      required this.localImage,
      required this.webImage,
      required this.startingFocalPoint,
      required this.onSelectFocalPoint})
      : super(key: key);

  @override
  State<ImageFocalPointSelection> createState() =>
      ImageFocalPointSelectionState();
}

class ImageFocalPointSelectionState extends State<ImageFocalPointSelection> {
  final GlobalKey imageKey = GlobalKey();
  Point markerPoint = const Point(-100.0, -100.0);
  FocalPoint focalPoint = FocalPoint(0.0, 0.0);

  void handleSubmit() {
    widget.onSelectFocalPoint(focalPoint);
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
    final size = getSize();
    double x = offset.dx;
    double y = offset.dy;

    if (x < 0 + pointSize / 2) x = pointSize / 2;
    if (y < 0 + pointSize / 2) y = pointSize / 2;
    if (x > size.width - pointSize / 2) {
      x = size.width - pointSize / 2;
    }
    if (y > size.height - pointSize / 2) {
      y = size.height - pointSize / 2;
    }

    setState(() {
      markerPoint = Point<double>(x - pointSize / 2, y - pointSize / 2);
      focalPoint = FocalPoint(x / size.width, y / size.height);
    });
  }

  Size getSize() {
    RenderBox renderBox =
        imageKey.currentContext?.findRenderObject() as RenderBox;
    return Size(renderBox.size.width, renderBox.size.height);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double x = widget.startingFocalPoint.x;
      double y = widget.startingFocalPoint.y;

      final size = getSize();
      setFocalPoint(Offset(size.width * x, size.height * y));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                              child: widget.localImage != null
                                  ? Image.file(widget.localImage!,
                                      key: imageKey)
                                  : widget.existingImage != null
                                      ? CachedNetworkImage(
                                          key: imageKey,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                                  child: SizedBox(
                                                      width: 30,
                                                      height: 30,
                                                      child: CircularProgressIndicator(
                                                          color: theme
                                                              .primaryColor))),
                                          imageUrl: getCloudflareImageUrl(widget
                                              .existingImage!.remoteImageId))
                                      : CachedNetworkImage(
                                          key: imageKey,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder:
                                              (context, url, downloadProgress) =>
                                                  Center(
                                                      child: SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child: CircularProgressIndicator(color: theme.primaryColor))),
                                          imageUrl: widget.webImage!.url)),
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
