import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/models/image_data_model.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:http/http.dart' as http;

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
      setState(() {
        images = sorted;
      });
    }

    Future<ImageData> uploadImage(File image) async {
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
              tags: []));
      if (imageModel == null) throw 'Error Uploading Image';

      return imageModel.item;
    }

    void handleAddImage(ImageSource source) async {
      try {
        final XFile? newImage = await imagePicker.pickImage(source: source);

        if (newImage == null) return;

        final file = File(newImage.path);
        setState(() {
          uploadingImages.insert(0, file);
        });

        await uploadImage(file);

        setState(() {
          uploadingImages.removeWhere((i) => i.path == file.path);
        });
      } catch (err) {
        log('image picker error: ');
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
          return ListView(children: [
            PrimaryButton(
                onPressed: () => handleAddImage(ImageSource.gallery),
                child: const Text('Add From Gallery')),
            const SizedBox(height: 8),
            PrimaryButton(
                child: const Text('Add From Camera'),
                onPressed: () => handleAddImage(ImageSource.camera)),
            const SizedBox(height: 8),
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
                                              child: CircularProgressIndicator(
                                                  color: theme.primaryColor))),
                                  imageUrl: getCloudflareImageUrl(
                                      imageData.remoteImageId))))
                          .toList()
                    ],
                  );
                })))
          ]);
        })));
  }
}
