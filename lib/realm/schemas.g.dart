// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Team extends _Team with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Team(
    ObjectId id,
    ObjectId ownerId,
    String title,
    String dependentName, {
    bool isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Team>({
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'dependentName', dependentName);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  Team._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get ownerId =>
      RealmObjectBase.get<ObjectId>(this, 'ownerId') as ObjectId;
  @override
  set ownerId(ObjectId value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get dependentName =>
      RealmObjectBase.get<String>(this, 'dependentName') as String;
  @override
  set dependentName(String value) =>
      RealmObjectBase.set(this, 'dependentName', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<Team>> get changes =>
      RealmObjectBase.getChanges<Team>(this);

  @override
  Team freeze() => RealmObjectBase.freezeObject<Team>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Team._);
    return const SchemaObject(ObjectType.realmObject, Team, 'Team', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.objectid),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('dependentName', RealmPropertyType.string),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
    ]);
  }
}

class TeamInvite extends _TeamInvite
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TeamInvite(
    ObjectId id,
    ObjectId teamId,
    String userType, {
    String? token,
    ObjectId? usedById,
    bool isUsed = false,
    bool isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TeamInvite>({
        'isUsed': false,
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'teamId', teamId);
    RealmObjectBase.set(this, 'userType', userType);
    RealmObjectBase.set(this, 'token', token);
    RealmObjectBase.set(this, 'usedById', usedById);
    RealmObjectBase.set(this, 'isUsed', isUsed);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  TeamInvite._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get teamId =>
      RealmObjectBase.get<ObjectId>(this, 'teamId') as ObjectId;
  @override
  set teamId(ObjectId value) => RealmObjectBase.set(this, 'teamId', value);

  @override
  String get userType =>
      RealmObjectBase.get<String>(this, 'userType') as String;
  @override
  set userType(String value) => RealmObjectBase.set(this, 'userType', value);

  @override
  String? get token => RealmObjectBase.get<String>(this, 'token') as String?;
  @override
  set token(String? value) => RealmObjectBase.set(this, 'token', value);

  @override
  ObjectId? get usedById =>
      RealmObjectBase.get<ObjectId>(this, 'usedById') as ObjectId?;
  @override
  set usedById(ObjectId? value) => RealmObjectBase.set(this, 'usedById', value);

  @override
  bool get isUsed => RealmObjectBase.get<bool>(this, 'isUsed') as bool;
  @override
  set isUsed(bool value) => RealmObjectBase.set(this, 'isUsed', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<TeamInvite>> get changes =>
      RealmObjectBase.getChanges<TeamInvite>(this);

  @override
  TeamInvite freeze() => RealmObjectBase.freezeObject<TeamInvite>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TeamInvite._);
    return const SchemaObject(
        ObjectType.realmObject, TeamInvite, 'TeamInvite', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('teamId', RealmPropertyType.objectid),
      SchemaProperty('userType', RealmPropertyType.string),
      SchemaProperty('token', RealmPropertyType.string, optional: true),
      SchemaProperty('usedById', RealmPropertyType.objectid, optional: true),
      SchemaProperty('isUsed', RealmPropertyType.bool),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
    ]);
  }
}

class Event extends _Event with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Event(
    ObjectId id,
    ObjectId teamId,
    ObjectId ownerId,
    String title,
    String description,
    DateTime startDateTime,
    int duration,
    bool isRecurring, {
    ObjectId? parentEventId,
    ImageData? image,
    LocationData? location,
    bool isCompleted = false,
    bool isTemplate = false,
    RecurrencePattern? recurrencePattern,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool isDeleted = false,
    Iterable<EventTask> tasks = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Event>({
        'isCompleted': false,
        'isTemplate': false,
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'teamId', teamId);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'parentEventId', parentEventId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'startDateTime', startDateTime);
    RealmObjectBase.set(this, 'duration', duration);
    RealmObjectBase.set(this, 'image', image);
    RealmObjectBase.set(this, 'location', location);
    RealmObjectBase.set(this, 'isRecurring', isRecurring);
    RealmObjectBase.set(this, 'isCompleted', isCompleted);
    RealmObjectBase.set(this, 'isTemplate', isTemplate);
    RealmObjectBase.set(this, 'recurrencePattern', recurrencePattern);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'completedAt', completedAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
    RealmObjectBase.set<RealmList<EventTask>>(
        this, 'tasks', RealmList<EventTask>(tasks));
  }

  Event._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get teamId =>
      RealmObjectBase.get<ObjectId>(this, 'teamId') as ObjectId;
  @override
  set teamId(ObjectId value) => RealmObjectBase.set(this, 'teamId', value);

  @override
  ObjectId get ownerId =>
      RealmObjectBase.get<ObjectId>(this, 'ownerId') as ObjectId;
  @override
  set ownerId(ObjectId value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  ObjectId? get parentEventId =>
      RealmObjectBase.get<ObjectId>(this, 'parentEventId') as ObjectId?;
  @override
  set parentEventId(ObjectId? value) =>
      RealmObjectBase.set(this, 'parentEventId', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  DateTime get startDateTime =>
      RealmObjectBase.get<DateTime>(this, 'startDateTime') as DateTime;
  @override
  set startDateTime(DateTime value) =>
      RealmObjectBase.set(this, 'startDateTime', value);

  @override
  int get duration => RealmObjectBase.get<int>(this, 'duration') as int;
  @override
  set duration(int value) => RealmObjectBase.set(this, 'duration', value);

  @override
  RealmList<EventTask> get tasks =>
      RealmObjectBase.get<EventTask>(this, 'tasks') as RealmList<EventTask>;
  @override
  set tasks(covariant RealmList<EventTask> value) =>
      throw RealmUnsupportedSetError();

  @override
  ImageData? get image =>
      RealmObjectBase.get<ImageData>(this, 'image') as ImageData?;
  @override
  set image(covariant ImageData? value) =>
      RealmObjectBase.set(this, 'image', value);

  @override
  LocationData? get location =>
      RealmObjectBase.get<LocationData>(this, 'location') as LocationData?;
  @override
  set location(covariant LocationData? value) =>
      RealmObjectBase.set(this, 'location', value);

  @override
  bool get isRecurring =>
      RealmObjectBase.get<bool>(this, 'isRecurring') as bool;
  @override
  set isRecurring(bool value) =>
      RealmObjectBase.set(this, 'isRecurring', value);

  @override
  bool get isCompleted =>
      RealmObjectBase.get<bool>(this, 'isCompleted') as bool;
  @override
  set isCompleted(bool value) =>
      RealmObjectBase.set(this, 'isCompleted', value);

  @override
  bool get isTemplate => RealmObjectBase.get<bool>(this, 'isTemplate') as bool;
  @override
  set isTemplate(bool value) => RealmObjectBase.set(this, 'isTemplate', value);

  @override
  RecurrencePattern? get recurrencePattern =>
      RealmObjectBase.get<RecurrencePattern>(this, 'recurrencePattern')
          as RecurrencePattern?;
  @override
  set recurrencePattern(covariant RecurrencePattern? value) =>
      RealmObjectBase.set(this, 'recurrencePattern', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  DateTime? get completedAt =>
      RealmObjectBase.get<DateTime>(this, 'completedAt') as DateTime?;
  @override
  set completedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'completedAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<Event>> get changes =>
      RealmObjectBase.getChanges<Event>(this);

  @override
  Event freeze() => RealmObjectBase.freezeObject<Event>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Event._);
    return const SchemaObject(ObjectType.realmObject, Event, 'Event', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('teamId', RealmPropertyType.objectid),
      SchemaProperty('ownerId', RealmPropertyType.objectid),
      SchemaProperty('parentEventId', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string),
      SchemaProperty('startDateTime', RealmPropertyType.timestamp),
      SchemaProperty('duration', RealmPropertyType.int),
      SchemaProperty('tasks', RealmPropertyType.object,
          linkTarget: 'EventTask', collectionType: RealmCollectionType.list),
      SchemaProperty('image', RealmPropertyType.object,
          optional: true, linkTarget: 'ImageData'),
      SchemaProperty('location', RealmPropertyType.object,
          optional: true, linkTarget: 'LocationData'),
      SchemaProperty('isRecurring', RealmPropertyType.bool),
      SchemaProperty('isCompleted', RealmPropertyType.bool),
      SchemaProperty('isTemplate', RealmPropertyType.bool),
      SchemaProperty('recurrencePattern', RealmPropertyType.object,
          optional: true, linkTarget: 'RecurrencePattern'),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('completedAt', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }
}

class LocationData extends _LocationData
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  LocationData(
    String name,
    String address,
    double lat,
    double long, {
    String? googlePlaceId,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'lat', lat);
    RealmObjectBase.set(this, 'long', long);
    RealmObjectBase.set(this, 'googlePlaceId', googlePlaceId);
  }

  LocationData._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get address => RealmObjectBase.get<String>(this, 'address') as String;
  @override
  set address(String value) => RealmObjectBase.set(this, 'address', value);

  @override
  double get lat => RealmObjectBase.get<double>(this, 'lat') as double;
  @override
  set lat(double value) => RealmObjectBase.set(this, 'lat', value);

  @override
  double get long => RealmObjectBase.get<double>(this, 'long') as double;
  @override
  set long(double value) => RealmObjectBase.set(this, 'long', value);

  @override
  String? get googlePlaceId =>
      RealmObjectBase.get<String>(this, 'googlePlaceId') as String?;
  @override
  set googlePlaceId(String? value) =>
      RealmObjectBase.set(this, 'googlePlaceId', value);

  @override
  Stream<RealmObjectChanges<LocationData>> get changes =>
      RealmObjectBase.getChanges<LocationData>(this);

  @override
  LocationData freeze() => RealmObjectBase.freezeObject<LocationData>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(LocationData._);
    return const SchemaObject(
        ObjectType.embeddedObject, LocationData, 'LocationData', [
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('address', RealmPropertyType.string),
      SchemaProperty('lat', RealmPropertyType.double),
      SchemaProperty('long', RealmPropertyType.double),
      SchemaProperty('googlePlaceId', RealmPropertyType.string, optional: true),
    ]);
  }
}

class EventTask extends _EventTask
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  EventTask(
    ObjectId id,
    ObjectId teamId,
    ObjectId ownerId,
    ObjectId eventId,
    String title,
    String description, {
    ObjectId? parentTaskId,
    ImageData? image,
    ObjectId? prevTaskId,
    ObjectId? nextTaskId,
    bool isCompleted = false,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<EventTask>({
        'isCompleted': false,
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'teamId', teamId);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'eventId', eventId);
    RealmObjectBase.set(this, 'parentTaskId', parentTaskId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'image', image);
    RealmObjectBase.set(this, 'prevTaskId', prevTaskId);
    RealmObjectBase.set(this, 'nextTaskId', nextTaskId);
    RealmObjectBase.set(this, 'isCompleted', isCompleted);
    RealmObjectBase.set(this, 'completedAt', completedAt);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  EventTask._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get teamId =>
      RealmObjectBase.get<ObjectId>(this, 'teamId') as ObjectId;
  @override
  set teamId(ObjectId value) => RealmObjectBase.set(this, 'teamId', value);

  @override
  ObjectId get ownerId =>
      RealmObjectBase.get<ObjectId>(this, 'ownerId') as ObjectId;
  @override
  set ownerId(ObjectId value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  ObjectId get eventId =>
      RealmObjectBase.get<ObjectId>(this, 'eventId') as ObjectId;
  @override
  set eventId(ObjectId value) => RealmObjectBase.set(this, 'eventId', value);

  @override
  ObjectId? get parentTaskId =>
      RealmObjectBase.get<ObjectId>(this, 'parentTaskId') as ObjectId?;
  @override
  set parentTaskId(ObjectId? value) =>
      RealmObjectBase.set(this, 'parentTaskId', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  ImageData? get image =>
      RealmObjectBase.get<ImageData>(this, 'image') as ImageData?;
  @override
  set image(covariant ImageData? value) =>
      RealmObjectBase.set(this, 'image', value);

  @override
  ObjectId? get prevTaskId =>
      RealmObjectBase.get<ObjectId>(this, 'prevTaskId') as ObjectId?;
  @override
  set prevTaskId(ObjectId? value) =>
      RealmObjectBase.set(this, 'prevTaskId', value);

  @override
  ObjectId? get nextTaskId =>
      RealmObjectBase.get<ObjectId>(this, 'nextTaskId') as ObjectId?;
  @override
  set nextTaskId(ObjectId? value) =>
      RealmObjectBase.set(this, 'nextTaskId', value);

  @override
  bool get isCompleted =>
      RealmObjectBase.get<bool>(this, 'isCompleted') as bool;
  @override
  set isCompleted(bool value) =>
      RealmObjectBase.set(this, 'isCompleted', value);

  @override
  DateTime? get completedAt =>
      RealmObjectBase.get<DateTime>(this, 'completedAt') as DateTime?;
  @override
  set completedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'completedAt', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<EventTask>> get changes =>
      RealmObjectBase.getChanges<EventTask>(this);

  @override
  EventTask freeze() => RealmObjectBase.freezeObject<EventTask>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(EventTask._);
    return const SchemaObject(ObjectType.realmObject, EventTask, 'EventTask', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('teamId', RealmPropertyType.objectid),
      SchemaProperty('ownerId', RealmPropertyType.objectid),
      SchemaProperty('eventId', RealmPropertyType.objectid),
      SchemaProperty('parentTaskId', RealmPropertyType.objectid,
          optional: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string),
      SchemaProperty('image', RealmPropertyType.object,
          optional: true, linkTarget: 'ImageData'),
      SchemaProperty('prevTaskId', RealmPropertyType.objectid, optional: true),
      SchemaProperty('nextTaskId', RealmPropertyType.objectid, optional: true),
      SchemaProperty('isCompleted', RealmPropertyType.bool),
      SchemaProperty('completedAt', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }
}

class ImageData extends _ImageData
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ImageData(
    ObjectId id,
    ObjectId teamId,
    ObjectId ownerId,
    String remoteImageId,
    bool isPublic, {
    String? title,
    double? aspectRatio,
    FocalPoint? focalPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted = false,
    Iterable<String> tags = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ImageData>({
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'teamId', teamId);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'remoteImageId', remoteImageId);
    RealmObjectBase.set(this, 'aspectRatio', aspectRatio);
    RealmObjectBase.set(this, 'focalPoint', focalPoint);
    RealmObjectBase.set(this, 'isPublic', isPublic);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
    RealmObjectBase.set<RealmList<String>>(
        this, 'tags', RealmList<String>(tags));
  }

  ImageData._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get teamId =>
      RealmObjectBase.get<ObjectId>(this, 'teamId') as ObjectId;
  @override
  set teamId(ObjectId value) => RealmObjectBase.set(this, 'teamId', value);

  @override
  ObjectId get ownerId =>
      RealmObjectBase.get<ObjectId>(this, 'ownerId') as ObjectId;
  @override
  set ownerId(ObjectId value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String? get title => RealmObjectBase.get<String>(this, 'title') as String?;
  @override
  set title(String? value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get remoteImageId =>
      RealmObjectBase.get<String>(this, 'remoteImageId') as String;
  @override
  set remoteImageId(String value) =>
      RealmObjectBase.set(this, 'remoteImageId', value);

  @override
  double? get aspectRatio =>
      RealmObjectBase.get<double>(this, 'aspectRatio') as double?;
  @override
  set aspectRatio(double? value) =>
      RealmObjectBase.set(this, 'aspectRatio', value);

  @override
  FocalPoint? get focalPoint =>
      RealmObjectBase.get<FocalPoint>(this, 'focalPoint') as FocalPoint?;
  @override
  set focalPoint(covariant FocalPoint? value) =>
      RealmObjectBase.set(this, 'focalPoint', value);

  @override
  RealmList<String> get tags =>
      RealmObjectBase.get<String>(this, 'tags') as RealmList<String>;
  @override
  set tags(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  bool get isPublic => RealmObjectBase.get<bool>(this, 'isPublic') as bool;
  @override
  set isPublic(bool value) => RealmObjectBase.set(this, 'isPublic', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<ImageData>> get changes =>
      RealmObjectBase.getChanges<ImageData>(this);

  @override
  ImageData freeze() => RealmObjectBase.freezeObject<ImageData>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ImageData._);
    return const SchemaObject(ObjectType.realmObject, ImageData, 'ImageData', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('teamId', RealmPropertyType.objectid),
      SchemaProperty('ownerId', RealmPropertyType.objectid),
      SchemaProperty('title', RealmPropertyType.string, optional: true),
      SchemaProperty('remoteImageId', RealmPropertyType.string),
      SchemaProperty('aspectRatio', RealmPropertyType.double, optional: true),
      SchemaProperty('focalPoint', RealmPropertyType.object,
          optional: true, linkTarget: 'FocalPoint'),
      SchemaProperty('tags', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('isPublic', RealmPropertyType.bool),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }
}

class FocalPoint extends _FocalPoint
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  FocalPoint(
    double x,
    double y,
  ) {
    RealmObjectBase.set(this, 'x', x);
    RealmObjectBase.set(this, 'y', y);
  }

  FocalPoint._();

  @override
  double get x => RealmObjectBase.get<double>(this, 'x') as double;
  @override
  set x(double value) => RealmObjectBase.set(this, 'x', value);

  @override
  double get y => RealmObjectBase.get<double>(this, 'y') as double;
  @override
  set y(double value) => RealmObjectBase.set(this, 'y', value);

  @override
  Stream<RealmObjectChanges<FocalPoint>> get changes =>
      RealmObjectBase.getChanges<FocalPoint>(this);

  @override
  FocalPoint freeze() => RealmObjectBase.freezeObject<FocalPoint>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(FocalPoint._);
    return const SchemaObject(
        ObjectType.embeddedObject, FocalPoint, 'FocalPoint', [
      SchemaProperty('x', RealmPropertyType.double),
      SchemaProperty('y', RealmPropertyType.double),
    ]);
  }
}

class RecurrencePattern extends _RecurrencePattern
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RecurrencePattern(
    ObjectId id,
    String recurrenceType,
    int interval,
    DateTime startDateTime,
    DateTime endDateTime,
    bool doesEnd, {
    int? count,
    Iterable<int> daysOfWeek = const [],
    Iterable<int> daysOfMonth = const [],
    Iterable<int> weeksOfMonth = const [],
    Iterable<int> monthsOfYear = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'recurrenceType', recurrenceType);
    RealmObjectBase.set(this, 'interval', interval);
    RealmObjectBase.set(this, 'startDateTime', startDateTime);
    RealmObjectBase.set(this, 'endDateTime', endDateTime);
    RealmObjectBase.set(this, 'doesEnd', doesEnd);
    RealmObjectBase.set(this, 'count', count);
    RealmObjectBase.set<RealmList<int>>(
        this, 'daysOfWeek', RealmList<int>(daysOfWeek));
    RealmObjectBase.set<RealmList<int>>(
        this, 'daysOfMonth', RealmList<int>(daysOfMonth));
    RealmObjectBase.set<RealmList<int>>(
        this, 'weeksOfMonth', RealmList<int>(weeksOfMonth));
    RealmObjectBase.set<RealmList<int>>(
        this, 'monthsOfYear', RealmList<int>(monthsOfYear));
  }

  RecurrencePattern._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get recurrenceType =>
      RealmObjectBase.get<String>(this, 'recurrenceType') as String;
  @override
  set recurrenceType(String value) =>
      RealmObjectBase.set(this, 'recurrenceType', value);

  @override
  int get interval => RealmObjectBase.get<int>(this, 'interval') as int;
  @override
  set interval(int value) => RealmObjectBase.set(this, 'interval', value);

  @override
  RealmList<int> get daysOfWeek =>
      RealmObjectBase.get<int>(this, 'daysOfWeek') as RealmList<int>;
  @override
  set daysOfWeek(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get daysOfMonth =>
      RealmObjectBase.get<int>(this, 'daysOfMonth') as RealmList<int>;
  @override
  set daysOfMonth(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get weeksOfMonth =>
      RealmObjectBase.get<int>(this, 'weeksOfMonth') as RealmList<int>;
  @override
  set weeksOfMonth(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get monthsOfYear =>
      RealmObjectBase.get<int>(this, 'monthsOfYear') as RealmList<int>;
  @override
  set monthsOfYear(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  DateTime get startDateTime =>
      RealmObjectBase.get<DateTime>(this, 'startDateTime') as DateTime;
  @override
  set startDateTime(DateTime value) =>
      RealmObjectBase.set(this, 'startDateTime', value);

  @override
  DateTime get endDateTime =>
      RealmObjectBase.get<DateTime>(this, 'endDateTime') as DateTime;
  @override
  set endDateTime(DateTime value) =>
      RealmObjectBase.set(this, 'endDateTime', value);

  @override
  bool get doesEnd => RealmObjectBase.get<bool>(this, 'doesEnd') as bool;
  @override
  set doesEnd(bool value) => RealmObjectBase.set(this, 'doesEnd', value);

  @override
  int? get count => RealmObjectBase.get<int>(this, 'count') as int?;
  @override
  set count(int? value) => RealmObjectBase.set(this, 'count', value);

  @override
  Stream<RealmObjectChanges<RecurrencePattern>> get changes =>
      RealmObjectBase.getChanges<RecurrencePattern>(this);

  @override
  RecurrencePattern freeze() =>
      RealmObjectBase.freezeObject<RecurrencePattern>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(RecurrencePattern._);
    return const SchemaObject(
        ObjectType.embeddedObject, RecurrencePattern, 'RecurrencePattern', [
      SchemaProperty('id', RealmPropertyType.objectid),
      SchemaProperty('recurrenceType', RealmPropertyType.string),
      SchemaProperty('interval', RealmPropertyType.int),
      SchemaProperty('daysOfWeek', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('daysOfMonth', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('weeksOfMonth', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('monthsOfYear', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
      SchemaProperty('startDateTime', RealmPropertyType.timestamp),
      SchemaProperty('endDateTime', RealmPropertyType.timestamp),
      SchemaProperty('doesEnd', RealmPropertyType.bool),
      SchemaProperty('count', RealmPropertyType.int, optional: true),
    ]);
  }
}

class CompletionRecord extends _CompletionRecord
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CompletionRecord(
    ObjectId id,
    ObjectId eventId,
    ObjectId teamId,
    ObjectId ownerId, {
    DateTime? recurringInstanceDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CompletionRecord>({
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'eventId', eventId);
    RealmObjectBase.set(this, 'teamId', teamId);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(
        this, 'recurringInstanceDateTime', recurringInstanceDateTime);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  CompletionRecord._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get eventId =>
      RealmObjectBase.get<ObjectId>(this, 'eventId') as ObjectId;
  @override
  set eventId(ObjectId value) => RealmObjectBase.set(this, 'eventId', value);

  @override
  ObjectId get teamId =>
      RealmObjectBase.get<ObjectId>(this, 'teamId') as ObjectId;
  @override
  set teamId(ObjectId value) => RealmObjectBase.set(this, 'teamId', value);

  @override
  ObjectId get ownerId =>
      RealmObjectBase.get<ObjectId>(this, 'ownerId') as ObjectId;
  @override
  set ownerId(ObjectId value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  DateTime? get recurringInstanceDateTime =>
      RealmObjectBase.get<DateTime>(this, 'recurringInstanceDateTime')
          as DateTime?;
  @override
  set recurringInstanceDateTime(DateTime? value) =>
      RealmObjectBase.set(this, 'recurringInstanceDateTime', value);

  @override
  DateTime? get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime?;
  @override
  set createdAt(DateTime? value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<CompletionRecord>> get changes =>
      RealmObjectBase.getChanges<CompletionRecord>(this);

  @override
  CompletionRecord freeze() =>
      RealmObjectBase.freezeObject<CompletionRecord>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CompletionRecord._);
    return const SchemaObject(
        ObjectType.realmObject, CompletionRecord, 'CompletionRecord', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('eventId', RealmPropertyType.objectid),
      SchemaProperty('teamId', RealmPropertyType.objectid),
      SchemaProperty('ownerId', RealmPropertyType.objectid),
      SchemaProperty('recurringInstanceDateTime', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }
}
