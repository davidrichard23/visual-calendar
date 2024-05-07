import 'dart:developer';
import 'dart:io';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/image_manager/screens/image_processor.dart';
import 'package:calendar/screens/image_manager/screens/web_image_search.dart';
import 'package:calendar/screens/image_manager/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageManager extends StatefulWidget {
  final Function(ImageData)? onChooseImage;

  const ImageManager({Key? key, this.onChooseImage}) : super(key: key);

  @override
  State<ImageManager> createState() => ImageManagerState();
}

class ImageManagerState extends State<ImageManager> {
  final ImagePicker imagePicker = ImagePicker();

  List<File> selectedLocalImages = [];
  List<WebImage> selectedWebImages = [];
  String imageFilter = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void goToImageProcessor(List<File> selectedImages) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageProcessor(
                  localImages: selectedImages, webImages: null)));
    }

    void handleAddImageFromLibrary() async {
      try {
        final List<XFile> images = await imagePicker.pickMultiImage();

        if (images.isEmpty) return;

        final files = images.map((e) => File(e.path)).toList();
        goToImageProcessor(files);
      } catch (err) {
        inspect(err);
      }
    }

    void handleAddImageFromCamera() async {
      try {
        final XFile? image =
            await imagePicker.pickImage(source: ImageSource.camera);

        if (image == null) return;

        final file = File(image.path);
        goToImageProcessor([file]);
      } catch (err) {
        inspect(err);
      }
    }

    void handleAddImageFromWebSearch() async {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const WebImageSearch()));
    }

    void handleSearchChange(String value) {
      setState(() {
        imageFilter = value.toLowerCase();
      });
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Images',
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          ),
          foregroundColor: theme.primaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Builder(builder: ((context) {
          return SafeArea(
              bottom: false,
              child: ListView(children: [
                Container(
                    color: theme.primaryColor,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                  elevation: 3, // Set the elevation
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  color: Colors
                                      .transparent, // Make the Material widget transparent
                                  child: InkWell(
                                    onTap: handleAddImageFromLibrary,
                                    child: Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.white, // button color
                                        shape: CircleBorder(),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            16.0), // button padding
                                        child: Icon(
                                          Icons.photo_library_outlined, // icon
                                          color:
                                              theme.primaryColor, // icon color
                                          size: 24.0, // icon size
                                        ),
                                      ),
                                    ),
                                  )),
                              const SizedBox(width: 16),
                              Material(
                                  elevation: 3, // Set the elevation
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  color: Colors
                                      .transparent, // Make the Material widget transparent
                                  child: InkWell(
                                    onTap: handleAddImageFromCamera,
                                    child: Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.white, // button color
                                        shape: CircleBorder(),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            16.0), // button padding
                                        child: Icon(
                                          Icons.camera_alt_outlined, // icon
                                          color:
                                              theme.primaryColor, // icon color
                                          size: 24.0, // icon size
                                        ),
                                      ),
                                    ),
                                  )),
                              const SizedBox(width: 16),
                              Material(
                                  elevation: 3, // Set the elevation
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  color: Colors
                                      .transparent, // Make the Material widget transparent
                                  child: InkWell(
                                    onTap: handleAddImageFromWebSearch,
                                    child: Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.white, // button color
                                        shape: CircleBorder(),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            16.0), // button padding
                                        child: Icon(
                                          Icons.search_outlined, // icon
                                          color:
                                              theme.primaryColor, // icon color
                                          size: 24.0, // icon size
                                        ),
                                      ),
                                    ),
                                  )),
                            ]))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CustomTextFormField(
                    hintText: 'Search',
                    initialValue: '',
                    textInputAction: TextInputAction.done,
                    onChanged: handleSearchChange,
                  ),
                ),
                ImageGrid(
                    onChooseImage: widget.onChooseImage, filter: imageFilter)
              ]));
        })));
  }
}
