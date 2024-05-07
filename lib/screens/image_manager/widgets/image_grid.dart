import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/data/realm_query_builder.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/image_manager/screens/image_processor.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/get_cloudflare_image_url.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

class ImageGrid extends StatefulWidget {
  final Function(ImageData)? onChooseImage;
  final String? filter;

  const ImageGrid({Key? key, this.onChooseImage, this.filter})
      : super(key: key);

  @override
  State<ImageGrid> createState() => ImageGridState();
}

class ImageGridState extends State<ImageGrid> {
  final ImagePicker imagePicker = ImagePicker();
  List<ImageData> allImages = [];

  void goToImageProcessor(ImageData image) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageProcessor(existingImages: [image])));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);
    List<ImageData> filteredImages;

    if (widget.filter != null) {
      filteredImages = allImages
          .where((element) =>
              element.tags.any((tag) => tag.startsWith(widget.filter!)))
          .toList();
    } else {
      filteredImages = allImages;
    }

    void onUpdate<T extends RealmObject>(RealmResults<T> newImageData) {
      var sorted = newImageData.toList() as List<ImageData>;
      sorted.sort((a, b) {
        return b.createdAt!.compareTo(a.createdAt!);
      });

      setState(() {
        allImages = sorted;
      });
    }

    var queryName = 'listImages-${appState.activeTeam!.id}';
    var queryString = "teamId == \$0 AND isDeleted == false";
    var queryArgs = [appState.activeTeam!.id];

    return RealmQueryBuilder<ImageData>(
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
              children: filteredImages
                  .map((imageData) => InkWell(
                      onTap: () {
                        if (widget.onChooseImage != null) {
                          widget.onChooseImage!(imageData);
                          Navigator.pop(context);
                          return;
                        }

                        goToImageProcessor(imageData);
                      },
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                                  child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                          color: theme.primaryColor))),
                          imageUrl:
                              getCloudflareImageUrl(imageData.remoteImageId))))
                  .toList());
        })));
  }
}
