import 'dart:developer';

import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class CompletionRecordModel {
  final ObjectId id;
  ObjectId eventId;
  ObjectId teamId;
  ObjectId ownerId;
  DateTime? recurringInstanceDateTime;
  bool isDeleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;

  late CompletionRecord item;
  final Realm realm;

  CompletionRecordModel._(
      this.realm,
      this.item,
      this.id,
      this.eventId,
      this.teamId,
      this.ownerId,
      this.recurringInstanceDateTime,
      this.isDeleted);
  CompletionRecordModel(Realm realm, CompletionRecord item)
      : this._(realm, item, item.id, item.eventId, item.teamId, item.ownerId,
            item.recurringInstanceDateTime, item.isDeleted);

  static CompletionRecordModel? create(Realm realm, CompletionRecord item) {
    try {
      var date = DateTime.now();
      item.createdAt = date;
      item.updatedAt = date;

      realm.write(() {
        realm.add<CompletionRecord>(item);
      });
      return CompletionRecordModel(realm, item);
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
