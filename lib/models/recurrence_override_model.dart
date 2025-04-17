import 'dart:developer';

import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class RecurrenceOverrideModel {
  final ObjectId id;
  ObjectId eventId;
  ObjectId teamId;
  ObjectId ownerId;
  DateTime recurringInstanceDateTime;
  bool isCancelled;
  String? title;
  String? description;
  late DateTime? startDateTime;
  int? duration;
  List<EventTask>? tasks;
  ImageData? image;
  LocationData? location;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;

  late RecurrenceOverride item;
  final Realm realm;

  RecurrenceOverrideModel._(
      this.realm,
      this.item,
      this.id,
      this.eventId,
      this.teamId,
      this.ownerId,
      this.recurringInstanceDateTime,
      this.isCancelled,
      this.title,
      this.description,
      this.startDateTime,
      this.duration,
      this.tasks,
      this.image,
      this.location,
      this.isDeleted);
  RecurrenceOverrideModel(Realm realm, RecurrenceOverride item)
      : this._(
            realm,
            item,
            item.id,
            item.eventId,
            item.teamId,
            item.ownerId,
            item.recurringInstanceDateTime,
            item.isCancelled,
            item.title,
            item.description,
            item.startDateTime,
            item.duration,
            item.tasks,
            item.image,
            item.location,
            item.isDeleted);

  static RecurrenceOverrideModel? create(Realm realm, RecurrenceOverride item,
      {List<EventTask>? tasks}) {
    try {
      var date = DateTime.now().toUtc();

      item.createdAt = date;
      item.updatedAt = date;
      item.isDeleted = false;

      realm.write(() {
        if (tasks != null) {
          for (var task in tasks) {
            task.createdAt = item.createdAt;
            task.updatedAt = item.updatedAt;
            final t = realm.add<EventTask>(task);
            item.tasks.add(t);
          }
          _rebuildTaskOrder(tasks);
        }
        realm.add<RecurrenceOverride>(item);
      });
      return RecurrenceOverrideModel(realm, item);
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

  static _rebuildTaskOrder(List<EventTask> tasks) {
    var i = 0;
    for (var task in tasks) {
      if (i != 0) {
        task.prevTaskId = tasks[i - 1].id;
      } else {
        task.prevTaskId = null;
      }
      if (i != tasks.length - 1) {
        task.nextTaskId = tasks[i + 1].id;
      } else {
        task.nextTaskId = null;
      }

      i++;
      continue;
    }
  }
}
