import 'dart:developer';

import 'package:calendar/models/event_task_model.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../realm/schemas.dart';

class EventModel {
  final ObjectId id;
  ObjectId teamId;
  ObjectId ownerId;
  ObjectId? parentEventId;
  String title;
  String description;
  late DateTime startDateTime;
  int duration;
  List<EventTask> tasks;
  ImageData? image;
  LocationData? location;
  bool isRecurring;
  bool isCompleted = false;
  bool isTemplate = false;
  RecurrencePattern? recurrencePattern;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;

  late Event item;
  final Realm realm;

  EventModel._(
      this.realm,
      this.item,
      this.id,
      this.teamId,
      this.ownerId,
      this.title,
      this.description,
      this.startDateTime,
      this.image,
      this.location,
      this.duration,
      this.tasks,
      this.isRecurring,
      this.isTemplate,
      this.isDeleted,
      this.recurrencePattern);
  EventModel(Realm realm, Event item)
      : this._(
            realm,
            item,
            item.id,
            item.teamId,
            item.ownerId,
            item.title,
            item.description,
            item.startDateTime,
            item.image,
            item.location,
            item.duration,
            item.tasks,
            item.isRecurring,
            item.isTemplate,
            item.isDeleted,
            item.recurrencePattern);

  static EventModel? create(Realm realm, Event item, List<EventTask> tasks) {
    try {
      var date = DateTime.now().toUtc();

      item.createdAt = date;
      item.updatedAt = date;
      item.isDeleted = false;

      realm.write(() {
        for (var task in tasks) {
          task.createdAt = item.createdAt;
          task.updatedAt = item.updatedAt;
          final t = realm.add<EventTask>(task);
          item.tasks.add(t);
        }
        _rebuildTaskOrder(tasks);

        realm.add<Event>(item);
      });
      return EventModel(realm, item);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  static EventModel? get(Realm realm, ObjectId id) {
    try {
      var item = realm.find<Event>(id);
      return EventModel(realm, item!);
    } on RealmException catch (e) {
      log(e.message);
      return null;
    }
  }

  void update(
      {String? title,
      String? description,
      DateTime? startDateTime,
      int? duration,
      bool? isRecurring,
      ImageData? image,
      LocationData? location,
      bool? isTemplate,
      RecurrencePattern? recurrencePattern,
      List<EventTask>? tasks}) {
    try {
      realm.write(() {
        if (title != null) item.title = title;
        if (description != null) item.description = description;
        if (startDateTime != null) item.startDateTime = startDateTime;
        if (duration != null) item.duration = duration;
        if (isTemplate != null) item.isTemplate = isTemplate;
        if (location != null) item.location = location;
        if (isRecurring != null) item.isRecurring = isRecurring;
        if (recurrencePattern != null) {
          item.recurrencePattern = recurrencePattern;
        }

        // always update image
        item.image = image;
        item.updatedAt = DateTime.now().toUtc();

        if (tasks == null) return;

        for (var task in tasks) {
          final isNew = !item.tasks.any((task2) => task2.id == task.id);
          if (isNew) {
            task.createdAt = item.updatedAt;
          }
          task.updatedAt = item.updatedAt;

          final t = realm.add<EventTask>(task, update: true);
          if (isNew) {
            item.tasks.add(t);
          }
        }
        _rebuildTaskOrder(tasks);
      });
    } on RealmException catch (e) {
      log(e.message);
    }
  }

  void sortTasks() {
    List<EventTask> sorted = [];

    // stupid
    while (sorted.length != tasks.length) {
      if (sorted.isEmpty) {
        var task = tasks.firstWhere((t) => t.prevTaskId == null);
        sorted.add(task);
      } else {
        var prevId = sorted.last.id;
        var task = tasks.firstWhere((t) => t.prevTaskId == prevId);
        sorted.add(task);
      }
    }

    tasks = sorted;
  }

  List<EventTask> duplicateTasks(ObjectId newEventId) {
    return tasks
        .map((task) => EventTask(ObjectId(), task.teamId, task.ownerId,
            newEventId, task.title, task.description,
            image: task.image))
        .toList();
  }

  void setStartDateTime(DateTime newStartDateTime) {
    try {
      realm.write(() {
        item.startDateTime = newStartDateTime.toUtc();
        item.updatedAt = DateTime.now().toUtc();
      });
    } on RealmException catch (e) {
      log(e.message);
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

  // static EventModel? list(Realm realm) {
  //   try {
  //     var item = realm.all<Event>();
  //     inspect(item);
  //     // return EventModel(realm, item!);
  //   } on RealmException catch (e) {
  //     log(e.message);
  //     return null;
  //   }
  // }

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
