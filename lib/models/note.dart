import 'package:dcache/dcache.dart';
import 'package:intl/intl.dart';
import 'package:onef/models/color_range.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class Note extends UpdatableModel<Note> {
  final int id;

  String title;
  String content;
  ColorRange color;
  NoteStatus status;

  User owner;
  String uuid;
  DateTime createdAt;
  DateTime modifiedAt;

  static final factory = TaskFactory();

  factory Note.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Note(
      {this.id,
      this.owner,
      this.title,
      this.content,
      this.color,
      this.status,
      this.uuid,
      this.createdAt,
      this.modifiedAt});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      title = json['title'];
    }

    if (json.containsKey('content')) {
      title = json['content'];
    }

    if (json.containsKey('color')) {
      color = factory.parseColor(json['color']);
    }

    if (json.containsKey('status')) {
      status = NoteStatus.parse(json['status']);
    }

    if (json.containsKey('uuid')) {
      uuid = json['uuid'];
    }

    if (json.containsKey('owner')) {
      owner = factory.parseUser(json['owner']);
    }

    if (json.containsKey('createdAt')) {
      createdAt = factory.parseCreated(json['createdAt']);
    }

    if (json.containsKey('modifiedAt')) {
      modifiedAt = factory.parseCreated(json['modifiedAt']);
    }
  }

  bool get pinned => status == NoteStatus.pinned;

  bool get isNotEmpty =>
      title?.isNotEmpty == true || content?.isNotEmpty == true;

  String get strLastModified => modifiedAt != null
      ? DateFormat.MMMd().format(modifiedAt)
      : DateFormat.MMMd().format(DateTime.now());

  bool hasTitle() {
    return title != null && title.length > 0;
  }

  bool hasContent() {
    return content != null && content.length > 0;
  }

  void setTitle(String title) {
    this.title = title;
    this.notifyUpdate();
  }

  void setContent(String content) {
    this.content = content;
    this.notifyUpdate();
  }

  void setStatus(NoteStatus status) {
    this.status = status;
    this.notifyUpdate();
  }

  Note copy({bool updateTimestamp = false}) => Note(
        id: id,
        createdAt:
            (updateTimestamp || createdAt == null) ? DateTime.now() : createdAt,
      )..updateFrom(this, updateTimestamp: updateTimestamp);

  void updateFrom(Note other, {bool updateTimestamp = true}) {
    title = other.title;
    content = other.content;
    color = other.color;
    status = other.status;

    owner = other.owner;
    uuid = other.uuid;
    if (updateTimestamp || other.modifiedAt == null) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other.modifiedAt;
    }
    this.notifyUpdate();
  }
}

class TaskFactory extends UpdatableModelFactory<Note> {
  @override
  SimpleCache<int, Note> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Note makeFromJson(Map json) {
    return Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        color: parseColor(json['color']),
        status: NoteStatus.parse(json['status']),
        createdAt: parseCreated(json['createdAt']),
        modifiedAt: parseCreated(json['modifiedAt']),
        owner: parseUser(json['creator']),
        uuid: json['uuid']);
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  UsersList parseUsers(List usersData) {
    if (usersData == null) return null;
    return UsersList.fromJson(usersData);
  }

  DateTime parseCreated(String created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

  ColorRange parseColor(Map colorData) {
    if (colorData == null) return null;
    return ColorRange.fromJson(colorData);
  }
}

class NoteStatus {
  final String code;

  const NoteStatus._internal(this.code);

  toString() => code;

  static const unspecified = const NoteStatus._internal('unspecified');
  static const pinned = const NoteStatus._internal('pinned');
  static const archived = const NoteStatus._internal('archived');
  static const deleted = const NoteStatus._internal('deleted');

  static const _values = const <NoteStatus>[
    unspecified,
    pinned,
    archived,
    deleted
  ];

  static values() => _values;

  static NoteStatus parse(String string) {
    if (string == null) return null;

    NoteStatus status;
    for (var type in _values) {
      if (string == type.code) {
        status = type;
        break;
      }
    }

    if (status == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported post status type: ' + string);
    }

    return status;
  }
}
