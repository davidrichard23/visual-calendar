import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/main.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';

class ImagePickerWidget extends StatefulWidget {
  final ImageData? image;
  final Function(ImageData?) setImage;

  const ImagePickerWidget({Key? key, this.image, required this.setImage})
      : super(key: key);

  @override
  State<ImagePickerWidget> createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  ImageData? selectedImage;

  void onSelectImage(ImageData newImage) {
    widget.setImage(newImage);
  }

  void goToImagePicker() {
    Navigator.pushNamed(context, '/image-manager',
        arguments: ImagesManagerArgs(onChooseImage: onSelectImage));
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    if (widget.image != null) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth - 32; // 32 margin
        double height = width / (widget.image?.aspectRatio ?? 1);

        return GestureDetector(
            onTap: goToImagePicker,
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                clipBehavior: Clip.hardEdge,
                height: height,
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(255, 161, 210, 198)),
                child: Stack(children: [
                  CachedNetworkImage(
                      fit: BoxFit.contain,
                      width: width,
                      height: height,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => SizedBox(
                              height: height,
                              width: width,
                              child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(
                                        color: Colors.white),
                                  ])),
                      imageUrl: getCloudflareImageUrl(
                          widget.image!.remoteImageId,
                          width: 600)),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: IconButton(
                        iconSize: 40,
                        icon: DecoratedIcon(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                            decoration: IconDecoration(
                                border: IconBorder(
                                    width: 1, color: Colors.grey[700]!))),
                        onPressed: () => setState(() {
                              widget.setImage(null);
                            })),
                  ),
                ])));
      });
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          height: 150,
          width: double.infinity,
          child: InkWell(
              splashColor: Colors.white.withOpacity(0.2),
              onTap: goToImagePicker,
              child: Ink(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 161, 210, 198),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: const Icon(Icons.add_circle_outline_rounded,
                              size: 32.0,
                              color: Color.fromARGB(255, 72, 128, 114))),
                      const Text(
                        'Add Image',
                        style: TextStyle(
                            color: Color.fromARGB(255, 72, 128, 114),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ))));
    }
  }
}
