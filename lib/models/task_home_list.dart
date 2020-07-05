import 'package:onef/models/task_home.dart';

class TaskHomeList {
  final List<TaskHome> taskHomes;

  TaskHomeList({
    this.taskHomes,
  });

  factory TaskHomeList.fromJson(List<dynamic> parsedJson) {
    List<TaskHome> taskHomes = parsedJson
        .map((taskHomeJson) => TaskHome.fromJSON(taskHomeJson))
        .toList();

    return new TaskHomeList(
      taskHomes: taskHomes,
    );
  }
}
