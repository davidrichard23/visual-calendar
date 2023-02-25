import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class EventTaskModel {
  final ObjectId id;
  ObjectId teamId;
  ObjectId ownerId;
  ObjectId eventId;
  ObjectId? parentTaskId;
  String title;
  String description;
  ImageData? image;
  ObjectId? prevTaskId;
  ObjectId? nextTaskId;
  bool isCompleted = false;
  late DateTime completedAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;

  late EventTask item;
  final Realm realm;

  EventTaskModel._(this.realm, this.item, this.id, this.teamId, this.ownerId,
      this.eventId, this.title, this.description, this.image);
  EventTaskModel(Realm realm, EventTask item)
      : this._(realm, item, item.id, item.teamId, item.ownerId, item.eventId,
            item.title, item.description, item.image);

  // static EventTaskModel? get(Realm realm, ObjectId id) {
  //   try {
  //     var item = realm.find<EventTask>(id);
  //     return EventTaskModel(realm, item!);
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return null;
  //   }
  // }

  static List<EventTaskModel>? list(Realm realm, ObjectId eventId) {
    try {
      var items = realm.query<EventTask>('eventId == \$0', [eventId]);
      return items
          .map<EventTaskModel>((item) => EventTaskModel(realm, item))
          .toList();
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  // bool complete() {
  //   try {
  //     realm.write(() {
  //       item.isComplete = true;
  //     });
  //     return true;
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return false;
  //   }
  // }

  // bool hasTasks() {
  //   try {
  //     final tasks = realm
  //         .all<EventTask>()
  //         .query('event == "${item.id}" AND isComplete = false');
  //     return tasks.isNotEmpty;
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return false;
  //   }
  // }

  // bool delete() {
  //   try {
  //     realm.write(() {
  //       item.isDeleted = true;
  //     });
  //     return true;
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return false;
  //   }
  // }
}
