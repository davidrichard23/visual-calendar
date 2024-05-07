import 'dart:developer';

import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class ImageDataModel {
  final ObjectId id;
  ObjectId teamId;
  ObjectId ownerId;
  String? title;
  String remoteImageId;
  List<String> tags = [];
  late double? aspectRatio; // optional for backwards compat
  late FocalPoint? focalPoint; // optional for backwards compat
  bool isPublic;
  bool isDeleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  late ImageData item;
  final Realm realm;

  ImageDataModel._(
      this.realm,
      this.item,
      this.id,
      this.teamId,
      this.ownerId,
      this.title,
      this.remoteImageId,
      this.tags,
      this.aspectRatio,
      this.focalPoint,
      this.isPublic,
      this.isDeleted);
  ImageDataModel(Realm realm, ImageData item)
      : this._(
            realm,
            item,
            item.id,
            item.teamId,
            item.ownerId,
            item.title,
            item.remoteImageId,
            item.tags,
            item.aspectRatio,
            item.focalPoint,
            item.isPublic,
            item.isDeleted);

  static ImageDataModel? create(Realm realm, ImageData item) {
    try {
      var date = DateTime.now();
      item.createdAt = date;
      item.updatedAt = date;

      realm.write(() {
        realm.add<ImageData>(item);
      });
      return ImageDataModel(realm, item);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  void update({List<String>? newTags, FocalPoint? newFocalPoint}) {
    try {
      realm.write(() {
        if (newTags != null) {
          item.tags.clear();
          item.tags.addAll(newTags);
        }
        if (newFocalPoint != null) item.focalPoint = newFocalPoint;
        item.updatedAt = DateTime.now().toUtc();
      });
    } on RealmException catch (e) {
      log(e.message);
    }
  }

  // static ImageDataModel? get(Realm realm, ObjectId id) {
  //   try {
  //     var item = realm.find<Image>(id);
  //     return ImageDataModel(realm, item!);
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return null;
  //   }
  // }

  bool delete() {
    try {
      realm.write(() {
        item.isDeleted = true;
      });
      return true;
    } on RealmException catch (e) {
      log(e.message);
      return false;
    }
  }
}
