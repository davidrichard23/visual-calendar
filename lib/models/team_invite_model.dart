import 'dart:developer';

import 'package:calendar/util/generate_INVITE_TOKEN.dart';
import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class TeamInviteModel {
  final ObjectId id;
  ObjectId teamId;
  String userType;
  ObjectId? usedById;
  bool isUsed = false;
  bool isDeleted = false;
  late String token;
  late DateTime createdAt;
  late DateTime updatedAt;

  late TeamInvite item;
  final Realm realm;

  TeamInviteModel._(this.realm, this.item, this.id, this.teamId, this.userType,
      this.isUsed, this.isDeleted, this.token);
  TeamInviteModel(Realm realm, TeamInvite item)
      : this._(realm, item, item.id, item.teamId, item.userType, item.isUsed,
            item.isDeleted, item.token!);

  static TeamInviteModel? create(Realm realm, TeamInvite item) {
    try {
      item.token = generateInviteToken();
      var date = DateTime.now();
      item.createdAt = date;
      item.updatedAt = date;

      realm.write(() {
        realm.add<TeamInvite>(item);
      });
      return TeamInviteModel(realm, item);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  static TeamInviteModel? get(Realm realm, ObjectId id) {
    try {
      var item = realm.find<TeamInvite>(id);
      return TeamInviteModel(realm, item!);
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
