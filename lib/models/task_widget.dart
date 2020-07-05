import 'package:dcache/dcache.dart';
import 'package:onef/models/color_range.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class TaskWidget extends UpdatableModel<TaskWidget> {
  final int id;

  String name;
  int qty;
  ColorRange color;
  TaskWidgetState state;
  bool hideCompletedTask;

  User owner;
  String uuid;
  DateTime created;

  static final factory = TaskWidgetFactory();

  factory TaskWidget.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toString(),
      'owner': owner?.toJson(),
      'uuid': uuid,
      'name': name,
      'qty': qty,
      'color': color?.toJson(),
      'state': state?.toString(),
      'hideCompletedTask': hideCompletedTask,
    };
  }

  TaskWidget(
      {this.id,
      this.name,
      this.qty,
      this.color,
      this.state,
      this.hideCompletedTask,
      this.owner,
      this.uuid,
      this.created});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('qty')) {
      qty = json['qty'];
    }

    if (json.containsKey('color')) {
      color = factory.parseColor(json['color']);
    }

    if (json.containsKey('state')) {
      state = TaskWidgetState.parse(json['state']);
    }

    if (json.containsKey('hideCompletedTask'))
      hideCompletedTask = json['hideCompletedTask'];

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

class TaskWidgetFactory extends UpdatableModelFactory<TaskWidget> {
  @override
  SimpleCache<int, TaskWidget> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  TaskWidget makeFromJson(Map json) {
    return TaskWidget(
        id: json['id'],
        name: json['name'],
        qty: json['qty'],
        color: parseColor(json['color']),
        state: TaskWidgetState.parse(json['state']),
        hideCompletedTask: json['hideCompletedTask'],
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

  ColorRange parseColor(Map colorData) {
    if (colorData == null) return null;
    return ColorRange.fromJson(colorData);
  }
}

class TaskWidgetState {
  final String code;

  const TaskWidgetState._internal(this.code);

  toString() => code;

  static const Today = const TaskWidgetState._internal('Today');
  static const Scheduled = const TaskWidgetState._internal('Scheduled');
  static const All = const TaskWidgetState._internal('All');
  static const Flagged = const TaskWidgetState._internal('Flagged');

  static const _values = const <TaskWidgetState>[
    Today,
    Scheduled,
    All,
    Flagged
  ];

  static values() => _values;

  static TaskWidgetState parse(String string) {
    if (string == null) return null;

    TaskWidgetState taskWidgetState;

    for (var keyword in _values) {
      if (string == keyword.code) {
        taskWidgetState = keyword;
        break;
      }
    }

    if (TaskWidgetState == null) {
      print('Unsupported task widget state');
    }

    return taskWidgetState;
  }
}
