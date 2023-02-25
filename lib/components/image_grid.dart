import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<ImageProvider> images;

  const ImageGrid({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return Image(image: images[index], fit: BoxFit.cover);
        });
  }
}
