import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/image_data_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/image_manager/screens/image_focal_point_selection.dart';
import 'package:calendar/screens/image_manager/screens/web_image_search.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:sheet/route.dart';
import 'package:path/path.dart' as path;

class ImageProcessor extends StatefulWidget {
  final List<ImageData>? existingImages;
  final List<File>? localImages;
  final List<WebImage>? webImages;

  const ImageProcessor(
      {Key? key, this.existingImages, this.localImages, this.webImages})
      : super(key: key);

  @override
  State<ImageProcessor> createState() => ImageManagerState();
}

class ImageManagerState extends State<ImageProcessor> {
  final tagController = TextEditingController();
  int currentImageIndex = 0;
  FocalPoint currentImageFocalPoint = FocalPoint(0.5, 0.5);
  List<String> currentImageTags = [];
  int uploadingImageCount = 0;
  bool loading = false;
  String? error;

  @override
  void initState() {
    inspect(widget.existingImages);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingImages != null) {
        final image = widget.existingImages![currentImageIndex];
        setState(() {
          currentImageTags = List.from(image.tags);
          if (image.focalPoint != null) {
            currentImageFocalPoint =
                FocalPoint(image.focalPoint!.x, image.focalPoint!.y);
          }
        });
      }
    });
  }

  void onSelectFocalPoint(FocalPoint focalPoint) {
    setState(() {
      currentImageFocalPoint = focalPoint;
    });
  }

  void goToFocalPointScreen() {
    final existingImage = widget.existingImages?[currentImageIndex];
    final localImage = widget.localImages?[currentImageIndex];
    final webImage = widget.webImages?[currentImageIndex];

    Navigator.push(
        context,
        CupertinoSheetRoute<void>(
            builder: (BuildContext newContext) => ImageFocalPointSelection(
                existingImage: existingImage,
                localImage: localImage,
                webImage: webImage,
                startingFocalPoint: currentImageFocalPoint,
                onSelectFocalPoint: onSelectFocalPoint)));
  }

  Size getFileImageSize(File image) {
    final Size size = ImageSizeGetter.getSize(FileInput(image));
    var width = size.width;
    var height = size.height;

    if (size.needRotate) {
      width = size.height;
      height = size.width;
    }

    return Size(width, height);
  }

  double getFileAspectRatio(File image) {
    final size = getFileImageSize(image);
    return size.width / size.height;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);
    final app = Provider.of<AppServices>(context, listen: true);
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final theme = Theme.of(context);

    int totalImages = 0;
    if (widget.existingImages != null) {
      totalImages = widget.existingImages!.length;
    }
    if (widget.localImages != null) {
      totalImages = widget.localImages!.length;
    }
    if (widget.webImages != null) {
      totalImages = widget.webImages!.length;
    }

    final isLastImage = currentImageIndex == totalImages - 1;

    Future<String> uploadImageToCloudflare(File image) async {
      final res = await app.currentUser!.functions.call('getImageUploadUrl');

      if (!res['success']) throw res['error'];

      final uploadUrl = res['results']['uploadURL'];

      var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
      var pic = await http.MultipartFile.fromPath("file", image.path);
      request.files.add(pic);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var uploadRes = jsonDecode(responseString);

      final imageId = uploadRes['result']['id'];
      return imageId;
    }

    Future<File> downloadImage(WebImage image, int index) async {
      final response = await http.get(Uri.parse(image.url));
      final tempDirectory = await getTemporaryDirectory();
      final file = File(path.join(tempDirectory.path, 'web-image-$index'));

      await file.writeAsBytes(response.bodyBytes);

      return file;
    }

    Future<void> saveWebImage(WebImage image, int index, List<String> tags,
        FocalPoint focalPoint) async {
      final file = await downloadImage(image, index);
      final imageId = await uploadImageToCloudflare(file);

      final imageModel = ImageDataModel.create(
          realmManager.realm!,
          ImageData(ObjectId(), appState.activeTeam!.id,
              ObjectId.fromHexString(app.currentUser!.id), imageId, false,
              tags: tags,
              focalPoint: focalPoint,
              aspectRatio: image.size.width / image.size.height));

      if (imageModel == null) throw 'Error Uploading Image';
    }

    Future<void> saveFileImage(
        File image, List<String> tags, FocalPoint focalPoint) async {
      final imageId = await uploadImageToCloudflare(image);
      final imageModel = ImageDataModel.create(
          realmManager.realm!,
          ImageData(ObjectId(), appState.activeTeam!.id,
              ObjectId.fromHexString(app.currentUser!.id), imageId, false,
              tags: tags,
              focalPoint: focalPoint,
              aspectRatio: getFileAspectRatio(image)));
      if (imageModel == null) throw 'Error Uploading Image';
    }

    void updateImage(
        ImageData image, List<String> tags, FocalPoint focalPoint) {
      final imageModel = ImageDataModel(realmManager.realm!, image);
      imageModel.update(newTags: tags, newFocalPoint: focalPoint);
    }

    void handleSave() async {
      uploadingImageCount++;

      // cache the current state
      final imageIndex = currentImageIndex;
      final tags = [...currentImageTags];
      final focalPoint =
          FocalPoint(currentImageFocalPoint.x, currentImageFocalPoint.y);

      if (isLastImage) {
        setState(() {
          loading = true;
        });
      } else {
        tagController.clear();

        setState(() {
          currentImageIndex++;
          currentImageTags.clear();
        });
      }

      if (widget.existingImages != null) {
        updateImage(widget.existingImages![imageIndex], tags, focalPoint);
        Navigator.pop(context);
        return;
      }
      if (widget.localImages != null) {
        await saveFileImage(widget.localImages![imageIndex], tags, focalPoint);
      }
      if (widget.webImages != null) {
        await saveWebImage(
            widget.webImages![imageIndex], imageIndex, tags, focalPoint);
      }

      uploadingImageCount--;

      if (isLastImage && uploadingImageCount == 0) {
        int popCount = widget.webImages != null ? 2 : 1;
        int i = 0;

        // ignore: use_build_context_synchronously
        Navigator.popUntil(context, (route) {
          return i++ == popCount; // pop 2 screens
        });
      }
    }

    void handleDelete() async {
      bool? result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Image?'),
            content: const Text(
                'If this image is used in any events, it will be removed from those events.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(
                      false); // dismisses only the dialog and returns false
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pop(true); // dismisses only the dialog and returns true
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (result != null && result) {
        final imageModel = ImageDataModel(
            realmManager.realm!, widget.existingImages![currentImageIndex]);
        imageModel.delete();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    }

    void addTag(String value) {
      if (value == '') return;
      if (currentImageTags.contains(value.toLowerCase())) return;
      setState(() {
        currentImageTags.add(value.toLowerCase());
      });
      tagController.clear();
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Save Image',
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          ),
          foregroundColor: theme.primaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: handleDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red[400])
          ],
        ),
        body: Builder(builder: ((context) {
          return Column(children: [
            Expanded(
                child: Stack(children: [
              SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        if (widget.existingImages != null)
                          CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                              color: theme.primaryColor))),
                              imageUrl: getCloudflareImageUrl(widget
                                  .existingImages![currentImageIndex]
                                  .remoteImageId)),
                        if (widget.webImages != null)
                          CachedNetworkImage(
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                      child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                              color: theme.primaryColor))),
                              imageUrl:
                                  widget.webImages![currentImageIndex].url),
                        if (widget.localImages != null)
                          Image.file(widget.localImages![currentImageIndex]),
                        const SizedBox(height: 16),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PrimaryButton(
                                onPressed: goToFocalPointScreen,
                                child: const Text('Choose focal point'))),
                        const SizedBox(height: 24),
                        const Paragraph(
                            'Add tags to easily search for this image in the future',
                            small: true),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: CustomTextFormField(
                                  controller: tagController,
                                  hintText: 'Tag',
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: addTag)),
                          // const SizedBox(width: 16),
                          Material(
                              elevation: 4, // Set the elevation
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              color: Colors
                                  .transparent, // Make the Material widget transparent
                              child: InkWell(
                                onTap: () => addTag(tagController.value.text),
                                child: Ink(
                                  decoration: ShapeDecoration(
                                    color: theme.primaryColor, // button color
                                    shape: const CircleBorder(),
                                  ),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.all(12.0), // button padding
                                    child: Icon(
                                      Icons.add, // icon
                                      color: Colors.white, // icon color
                                      size: 24.0, // icon size
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 16),
                        ]),
                        Wrap(
                          spacing: 8,
                          runSpacing: -8,
                          children: currentImageTags
                              .map((e) => InputChip(
                                  label: Text(e,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  deleteIconColor: Colors.white,
                                  showCheckmark: false,
                                  selectedColor: theme.cardColor,
                                  selected: true,
                                  onDeleted: () {
                                    setState(() {
                                      currentImageTags.remove(e);
                                    });
                                  }))
                              .toList(),
                        ),
                        const SizedBox(height: 116),
                      ]))),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 100,
                  color: theme.primaryColor,
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: PrimaryButton(
                              color: Colors.white,
                              onPressed: handleSave,
                              isLoading: loading,
                              child: Paragraph(!isLastImage
                                  ? 'Next'
                                  : widget.existingImages != null
                                      ? 'Update'
                                      : 'Complete')))),
                ),
              ),
            ]))
          ]);
        })));
  }
}
