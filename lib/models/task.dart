import 'package:dcache/dcache.dart';
import 'package:onef/models/sub_task.dart';
import 'package:onef/models/sub_tasks_list.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class Task extends UpdatableModel<Task> {
  final int id;

  String name;
  String description;
  DateTime dueDate;
  bool isCompleted;
  bool isFlagged;
  bool active;
  SubTasksList subTasks;

  User owner;
  String uuid;
  DateTime created;

  static final factory = TaskFactory();

  factory Task.fromJSON(Map<String, dynamic> json) {
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
      'active': active,
      'sub_tasks': subTasks?.subTasks
          ?.map((SubTask subTask) => subTask.toJson())
          ?.toList(),
    };
  }

  Task(
      {this.id,
      this.name,
      this.description,
      this.dueDate,
      this.isCompleted,
      this.isFlagged,
      this.active,
      this.subTasks,
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

    if (json.containsKey('sub_tasks')) {
      subTasks = factory.parseSubTasks(json['sub_tasks']);
    }

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

class TaskFactory extends UpdatableModelFactory<Task> {
  @override
  SimpleCache<int, Task> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Task makeFromJson(Map json) {
    return Task(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        dueDate: json['due_date'],
        isCompleted: json['is_completed'],
        isFlagged: json['is_flagged'],
        active: json['active'],
        subTasks: parseSubTasks(json['sub_tasks']),
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

  SubTasksList parseSubTasks(List subTasksData) {
    if (subTasksData == null) return null;
    return SubTasksList.fromJson(subTasksData);
  }
}

class OFTaskStatus {
  final String code;

  const OFTaskStatus._internal(this.code);

  toString() => code;

  static const draft = const OFTaskStatus._internal('D');
  static const processing = const OFTaskStatus._internal('PG');
  static const published = const OFTaskStatus._internal('P');

  static const _values = const <OFTaskStatus>[draft, processing, published];

  static values() => _values;

  static OFTaskStatus parse(String string) {
    if (string == null) return null;

    OFTaskStatus taskStatus;
    for (var type in _values) {
      if (string == type.code) {
        taskStatus = type;
        break;
      }
    }

    if (taskStatus == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported post status type: ' + string);
    }

    return taskStatus;
  }
}
