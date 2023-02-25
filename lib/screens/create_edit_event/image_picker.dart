import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realm/realm.dart';

class ImagePickerWidget extends StatefulWidget {
  final ImageData? existingImage;
  final UploadImageData? pendingImage;
  final Function(File) addImage;
  final Function(ObjectId) removeImage;
  final Function() removeExistingImage;

  const ImagePickerWidget(
      {Key? key,
      this.existingImage,
      this.pendingImage,
      required this.addImage,
      required this.removeExistingImage,
      required this.removeImage})
      : super(key: key);

  @override
  State<ImagePickerWidget> createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker imagePicker = ImagePicker();

  void handleSelectImage() async {
    try {
      final XFile? newImage =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (newImage == null) return;

      final file = File(newImage.path);

      widget.addImage(file);
    } catch (err) {
      // log('image picker error: ');
      inspect(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.pendingImage != null) {
      return GestureDetector(
          onTap: handleSelectImage,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 161, 210, 198)),
              child: Stack(children: [
                Image(
                    image: FileImage(widget.pendingImage!.image),
                    fit: BoxFit.cover),
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
                            widget.removeImage(widget.pendingImage!.id);
                          })),
                ),
              ])));
    } else if (widget.existingImage != null) {
      return GestureDetector(
          onTap: handleSelectImage,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 161, 210, 198)),
              child: Stack(children: [
                CachedNetworkImage(
                    progressIndicatorBuilder: (context, url,
                            downloadProgress) =>
                        CircularProgressIndicator(color: theme.primaryColor),
                    imageUrl: getCloudflareImageUrl(
                        widget.existingImage!.remoteImageId)),
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
                            widget.removeExistingImage();
                          })),
                ),
              ])));
    } else {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: handleSelectImage,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color.fromARGB(255, 177, 218, 207)),
              height: 150,
              width: double.infinity,
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
                  Text(
                    'Add Image',
                    style: TextStyle(
                        color: Color.fromARGB(255, 72, 128, 114),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              )));
    }
  }
}
