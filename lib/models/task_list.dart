import 'package:dcache/dcache.dart';
import 'package:onef/models/color_range.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/tasks_list.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class TaskList extends UpdatableModel<TaskList> {
  final int id;

  String name;
  String description;
  ColorRange color;
  DateTime date;
  bool isCompleted;
  bool isFlagged;
  bool active;
  TasksList tasks;

  User owner;
  String uuid;
  DateTime created;

  static final factory = TaskListFactory();

  factory TaskList.fromJSON(Map<String, dynamic> json) {
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
      'color': color?.toJson(),
      'date': date?.toString(),
      'is_completed': isCompleted,
      'is_flagged': isFlagged,
      'active': active,
      'tasks': tasks?.tasks?.map((Task task) => task.toJson())?.toList(),
    };
  }

  TaskList(
      {this.id,
      this.name,
      this.description,
      this.color,
      this.date,
      this.isCompleted,
      this.isFlagged,
      this.active,
      this.tasks,
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

    if (json.containsKey('color')) {
      color = factory.parseColor(json['color']);
    }

    if (json.containsKey('date')) {
      date = factory.parseDate(json['date']);
    }

    if (json.containsKey('is_completed')) isCompleted = json['is_completed'];
    if (json.containsKey('is_flagged')) isFlagged = json['is_flagged'];
    if (json.containsKey('active')) isFlagged = json['active'];

    if (json.containsKey('tasks')) {
      tasks = factory.parseTasks(json['tasks']);
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

class TaskListFactory extends UpdatableModelFactory<TaskList> {
  @override
  SimpleCache<int, TaskList> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  TaskList makeFromJson(Map json) {
    return TaskList(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        color: parseColor(json['color']),
        date: parseDate(json['date']),
        isCompleted: json['is_completed'],
        isFlagged: json['is_flagged'],
        active: json['active'],
        tasks: parseTasks(json['tasks']),
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

  DateTime parseDate(String dueDate) {
    if (dueDate == null) return null;
    return DateTime.parse(dueDate).toLocal();
  }

  TasksList parseTasks(List tasksData) {
    if (tasksData == null) return null;
    return TasksList.fromJson(tasksData);
  }

  ColorRange parseColor(Map colorData) {
    if (colorData == null) return null;
    return ColorRange.fromJson(colorData);
  }
}
