import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class SubTask extends UpdatableModel<SubTask> {
  final int id;

  String name;
  String description;
  DateTime dueDate;
  bool isCompleted;
  bool isFlagged;
  bool active;

  User owner;
  String uuid;
  DateTime created;

  static final factory = SubTaskFactory();

  factory SubTask.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toString(),
      'owner': owner?.toJson(),
      'uuid': uuid,
      'name': name,
      'description': description,
      'due_date': dueDate?.toString(),
      'is_completed': isCompleted,
      'is_flagged': isFlagged,
      'active': active
    };
  }

  SubTask(
      {this.id,
      this.name,
      this.description,
      this.dueDate,
      this.isCompleted,
      this.isFlagged,
      this.active,
      this.owner,
      this.uuid,
      this.created});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('due_date')) {
      dueDate = factory.parseDueDate(json['due_date']);
    }

    if (json.containsKey('is_completed')) isCompleted = json['is_completed'];
    if (json.containsKey('is_flagged')) isFlagged = json['is_flagged'];
    if (json.containsKey('active')) isFlagged = json['active'];

    if (json.containsKey('uuid')) {
      uuid = json['uuid'];
    }

    if (json.containsKey('created')) {
      created = json['created'];
    }

    if (json.containsKey('owner')) {
      owner = factory.parseUser(json['owner']);
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }
  }
}

class SubTaskFactory extends UpdatableModelFactory<SubTask> {
  @override
  SimpleCache<int, SubTask> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  SubTask makeFromJson(Map json) {
    return SubTask(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        dueDate: json['due_date'],
        isCompleted: json['is_completed'],
        isFlagged: json['is_flagged'],
        active: json['active'],
        created: parseCreated(json['created']),
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

  DateTime parseDueDate(String dueDate) {
    if (dueDate == null) return null;
    return DateTime.parse(dueDate).toLocal();
  }
}
