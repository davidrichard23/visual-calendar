import 'dart:developer';

import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class TeamModel {
  final ObjectId id;
  ObjectId ownerId;
  String dependentName;
  String title;
  bool isDeleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  late Team item;
  final Realm realm;

  TeamModel._(this.realm, this.item, this.id, this.ownerId, this.dependentName,
      this.title, this.isDeleted);
  TeamModel(Realm realm, Team item)
      : this._(realm, item, item.id, item.ownerId, item.dependentName,
            item.title, item.isDeleted);

  static TeamModel? create(Realm realm, Team item) {
    try {
      var date = DateTime.now();
      item.createdAt = date;
      item.updatedAt = date;

      realm.write(() {
        realm.add<Team>(item);
      });
      return TeamModel(realm, item);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  static TeamModel? get(Realm realm, ObjectId id) {
    try {
      var item = realm.find<Team>(id);
      return TeamModel(realm, item!);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

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
