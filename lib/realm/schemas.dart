import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Team {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId ownerId;
  late String title;
  late String dependentName;
  bool isDeleted = false;
  late DateTime? createdAt;
  late DateTime? updatedAt;
}

@RealmModel()
class _TeamInvite {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId teamId;
  late String userType; // caregiver || dependent
  late String? token;
  late ObjectId? usedById;
  bool isUsed = false;
  bool isDeleted = false;
  late DateTime? createdAt;
  late DateTime? updatedAt;
}

@RealmModel()
class _Event {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId teamId;
  late ObjectId ownerId;
  late ObjectId? parentEventId;
  late String title;
  late String description;
  late DateTime startDateTime;
  late int duration;
  late List<_EventTask> tasks = [];
  late _ImageData? image;
  late _LocationData? location;
  late bool isRecurring;
  late bool isCompleted = false; // Not used?
  late bool isTemplate = false;
  late _RecurrencePattern? recurrencePattern;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  late DateTime? completedAt;
  bool isDeleted = false;
}

@RealmModel(ObjectType.embeddedObject)
class _LocationData {
  late String name;
  late String address;
  late double lat;
  late double long;
  late String? googlePlaceId;
}

@RealmModel()
class _EventTask {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId teamId;
  late ObjectId ownerId;
  late ObjectId eventId;
  late ObjectId? parentTaskId;
  late String title;
  late String description;
  late _ImageData? image;
  late ObjectId? prevTaskId;
  late ObjectId? nextTaskId;
  bool isCompleted = false;
  late DateTime? completedAt;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  bool isDeleted = false;
}

@RealmModel()
class _ImageData {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId teamId;
  late ObjectId ownerId;
  late String? title;
  late String remoteImageId;
  late double? aspectRatio;
  late _FocalPoint? focalPoint;
  late List<String> tags;
  late bool isPublic;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  bool isDeleted = false;
}

@RealmModel(ObjectType.embeddedObject)
class _FocalPoint {
  late double x;
  late double y;
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

@RealmModel(ObjectType.embeddedObject)
class _RecurrencePattern {
  late ObjectId id;
  late String recurrenceType;
  late int interval;
  late List<int> daysOfWeek;
  late List<int> daysOfMonth;
  late List<int> weeksOfMonth;
  late List<int> monthsOfYear;
  late DateTime startDateTime;
  late DateTime endDateTime;
  late bool doesEnd;
  late int? count;
}

@RealmModel()
class _CompletionRecord {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId eventId;
  late ObjectId teamId;
  late ObjectId ownerId;
  late DateTime? recurringInstanceDateTime;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  bool isDeleted = false;
}

@RealmModel()
class _RecurrenceOverride {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late ObjectId eventId;
  late ObjectId teamId;
  late ObjectId ownerId;
  late DateTime recurringInstanceDateTime;
  late bool isCancelled;
  late String? title;
  late String? description;
  late DateTime? startDateTime;
  late int? duration;
  late List<_EventTask> tasks = [];
  late _ImageData? image;
  late _LocationData? location;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  bool isDeleted = false;
}
