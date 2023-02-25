import 'dart:developer';

import 'package:realm/realm.dart';
import '../realm/schemas.dart';

// TODO: add aspect ratio

class ImageDataModel {
  final ObjectId id;
  ObjectId teamId;
  ObjectId ownerId;
  String? title;
  String remoteImageId;
  List<String> tags = [];
  bool isPublic;
  bool isDeleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  late ImageData item;
  final Realm realm;

  ImageDataModel._(this.realm, this.item, this.id, this.teamId, this.ownerId,
      this.title, this.remoteImageId, this.tags, this.isPublic, this.isDeleted);
  ImageDataModel(Realm realm, ImageData item)
      : this._(realm, item, item.id, item.teamId, item.ownerId, item.title,
            item.remoteImageId, item.tags, item.isPublic, item.isDeleted);

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
