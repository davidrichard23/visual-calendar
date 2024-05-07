import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:calendar/screens/image_manager/screens/image_processor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

// int lastSearchTime = 0;
// int seachDebounceTime = 1000;

class WebImage {
  final String url;
  final String thumbnailUrl;
  final Size size;

  WebImage({required this.url, required this.thumbnailUrl, required this.size});
}

class WebImageSearch extends StatefulWidget {
  const WebImageSearch({Key? key}) : super(key: key);

  @override
  State<WebImageSearch> createState() => ImageManagerState();
}

class ImageManagerState extends State<WebImageSearch> {
  final myFocusNode = FocusNode();

  String searchString = '';
  List<WebImage> webImages = [];
  List<WebImage> selectedImages = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppServices>(context, listen: true);
    final theme = Theme.of(context);

    void goToImageProcessor() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageProcessor(
                  localImages: null, webImages: selectedImages)));
    }

    void handleSearchChange(String value) async {
      setState(() {
        searchString = value;
      });
    }

    void searchImages() async {
      setState(() {
        loading = true;
        error = null;
        selectedImages = [];
      });

      try {
        final res = await app.currentUser!.functions
            .call('webImageSearch', [searchString]);

        if (!res['success']) throw res['error'];

        final searchResults = res['results'];
        List<WebImage> newWebImages = [];

        searchResults.forEach((result) {
          newWebImages.add(WebImage(
              url: result['link'],
              thumbnailUrl: result['image']['thumbnailLink'],
              size: Size(
                  double.parse(result['image']['width']['\$numberDouble']),
                  double.parse(result['image']['height']['\$numberDouble']))));
        });

        setState(() {
          loading = false;
          webImages = newWebImages;
        });
      } on AppException catch (err) {
        setState(() {
          loading = false;
          error = err.message;
        });
      }
    }

    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Web Search',
            style: TextStyle(color: Colors.black.withOpacity(0.7)),
          ),
          foregroundColor: theme.primaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: <Widget>[
            if (selectedImages.isNotEmpty)
              TextButton(
                  onPressed: goToImageProcessor,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(17, 182, 141, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  child: const Text('Next'))
          ],
        ),
        body: Builder(builder: ((context) {
          return SafeArea(
              bottom: false,
              child: ListView(children: [
                if (error != null)
                  Text('Error ${error!}',
                      style: const TextStyle(color: Colors.red)),
                Container(
                    color: theme.primaryColor,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(children: [
                          Expanded(
                            child: CustomTextFormField(
                              focusNode: myFocusNode,
                              hintText: 'Search',
                              initialValue: '',
                              textInputAction: TextInputAction.done,
                              onChanged: handleSearchChange,
                              onSubmitted: (str) => searchImages(),
                            ),
                          ),
                          Material(
                              elevation: 4, // Set the elevation
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              color: Colors
                                  .transparent, // Make the Material widget transparent
                              child: InkWell(
                                onTap: () {
                                  if (loading) return;
                                  searchImages();
                                },
                                child: Ink(
                                  decoration: const ShapeDecoration(
                                    color: Colors.white, // button color
                                    shape: CircleBorder(),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        12.0), // button padding
                                    child: loading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: theme.primaryColor,
                                            ),
                                          )
                                        : Icon(
                                            Icons.search, // icon
                                            color: theme
                                                .primaryColor, // icon color
                                            size: 24.0, // icon size
                                          ),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 16),
                        ]))),
                // Padding(
                //     padding:
                //         const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                //     child: PrimaryButton(
                //         onPressed: searchImages,
                //         isLoading: loading,
                //         isDisabled: searchString.length < 2 || loading,
                //         child: const Text('Search'))),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  children: [
                    // ...uploadingImages.map((file) => Stack(children: [
                    //       Image(
                    //           width: double.infinity,
                    //           height: double.infinity,
                    //           image: FileImage(file),
                    //           fit: BoxFit.cover),
                    //       Container(color: Colors.black.withOpacity(0.4)),
                    //       Center(
                    //           child: SizedBox(
                    //               width: 30,
                    //               height: 30,
                    //               child: CircularProgressIndicator(
                    //                   color: theme.primaryColor)))
                    //     ])),
                    ...webImages.map((imageData) {
                      final isSelected = selectedImages.any((selectedImage) =>
                          selectedImage.url == imageData.url);

                      return InkWell(
                          onTap: () {
                            // widget.onSelectImage(imageData);
                            // Navigator.pop(context);
                            if (isSelected) {
                              setState(() {
                                selectedImages = selectedImages
                                    .where((selectedImage) =>
                                        selectedImage.url != imageData.url)
                                    .toList();
                              });
                            } else {
                              setState(() {
                                selectedImages.add(imageData);
                              });
                            }
                          },
                          child: Stack(fit: StackFit.expand, children: [
                            CachedNetworkImage(
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                        child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                                color: theme.primaryColor))),
                                imageUrl: imageData.thumbnailUrl),
                            if (isSelected)
                              Container(
                                color: Colors.black.withOpacity(0.4),
                                child: Center(
                                  child: Icon(
                                      Icons.check_circle_outline_outlined,
                                      color: theme.primaryColor,
                                      size: 40),
                                ),
                              )
                          ]));
                    }).toList()
                  ],
                )
              ]));
        })));
  }
}
