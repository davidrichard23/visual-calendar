import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/image_data_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/image_focal_point_selection_screen.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:http/http.dart' as http;
import 'package:sheet/route.dart';

var isSimulator = false;

class ImagesScreen extends StatefulWidget {
  final Function(ImageData) onSelectImage;

  const ImagesScreen({Key? key, required this.onSelectImage}) : super(key: key);

  @override
  State<ImagesScreen> createState() => ImagesScreenState();
}

class ImagesScreenState extends State<ImagesScreen> {
  final ImagePicker imagePicker = ImagePicker();
  List<ImageData> images = [];
  List<File> uploadingImages = [];

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);
    final app = Provider.of<AppServices>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    void onUpdate<T extends RealmObject>(RealmResults<T> newImageData) {
      var sorted = newImageData.toList() as List<ImageData>;
      sorted.sort((a, b) {
        return b.createdAt!.compareTo(a.createdAt!);
      });
      // log(sorted.length.toString());
      inspect(sorted);
      setState(() {
        images = sorted;
      });
    }

    Size getImageSize(File image) {
      final size = ImageSizeGetter.getSize(FileInput(image));
      var width = size.width;
      var height = size.height;

      if (size.needRotate) {
        width = size.height;
        height = size.width;
      }

      return Size(width, height);
    }

    double getAspectRatio(File image) {
      final size = getImageSize(image);
      return size.width / size.height;
    }

    Future<void> uploadImage(File image, FocalPoint focalPoint) async {
      try {
        setState(() {
          uploadingImages.insert(0, image);
        });

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
        final imageModel = ImageDataModel.create(
            realmManager.realm!,
            ImageData(ObjectId(), appState.activeTeam!.id,
                ObjectId.fromHexString(app.currentUser!.id), imageId, false,
                tags: [],
                focalPoint: focalPoint,
                aspectRatio: getAspectRatio(image)));
        if (imageModel == null) throw 'Error Uploading Image';

        setState(() {
          uploadingImages.removeWhere((i) => i.path == image.path);
        });
      } catch (err) {
        inspect(err);
      }
    }

    void handleAddImage(ImageSource source) async {
      try {
        final XFile? newImage = await imagePicker.pickImage(source: source);

        if (newImage == null) return;

        final file = File(newImage.path);
        final aspectRatio = getAspectRatio(file);

        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialExtendedPageRoute(
                fullscreenDialog: true,
                builder: (context) => ImageFocalPointSelectionScreen(
                    image: file,
                    aspectRatio: aspectRatio,
                    onSelectFocalPoint: uploadImage)));
      } catch (err) {
        inspect(err);
      }
    }

    var queryName = 'listImages-${appState.activeTeam!.id}';
    var queryString = "teamId == \$0";
    var queryArgs = [appState.activeTeam!.id];

    return Scaffold(
        backgroundColor: Colors.white,
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
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MaxWidth(
                        maxWidth: maxWidth,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                              child: PrimaryButton(
                                  onPressed: () =>
                                      handleAddImage(ImageSource.gallery),
                                  child: const Text(
                                    'Add From Gallery',
                                    textAlign: TextAlign.center,
                                  ))),
                          const SizedBox(width: 16),
                          Flexible(
                              child: PrimaryButton(
                                  child: const Text(
                                    'Add From Camera',
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () =>
                                      handleAddImage(ImageSource.camera))),
                        ]))),
                const SizedBox(height: 24),
                const H1('Choose an Image:', center: true),
                const SizedBox(height: 24),
                if (images.isEmpty)
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Paragraph(
                          'You have not added any images to your team. Please add one using the buttons above.')),
                RealmQueryBuilder<ImageData>(
                    onUpdate: onUpdate,
                    queryName: queryName,
                    queryString: queryString,
                    queryArgs: queryArgs,
                    queryType: QueryType.queryString,
                    child: Builder(builder: ((context) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        children: [
                          ...uploadingImages.map((file) => Stack(children: [
                                Image(
                                    width: double.infinity,
                                    height: double.infinity,
                                    image: FileImage(file),
                                    fit: BoxFit.cover),
                                Container(color: Colors.black.withOpacity(0.4)),
                                Center(
                                    child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                            color: theme.primaryColor)))
                              ])),
                          ...images
                              .map((imageData) => InkWell(
                                  onTap: () {
                                    widget.onSelectImage(imageData);
                                    Navigator.pop(context);
                                  },
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          Center(
                                              child: SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: theme
                                                              .primaryColor))),
                                      imageUrl: getCloudflareImageUrl(
                                          imageData.remoteImageId))))
                              .toList()
                        ],
                      );
                    })))
              ]));
        })));
  }
}
