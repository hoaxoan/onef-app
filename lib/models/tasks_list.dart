import 'package:onef/models/task.dart';

class TasksList {
  final List<Task> tasks;

  TasksList({
    this.tasks,
  });

  factory TasksList.fromJson(List<dynamic> parsedJson) {
    List<Task> tasks =
        parsedJson.map((taskJson) => Task.fromJSON(taskJson)).toList();

    return new TasksList(
      tasks: tasks,
    );
  }
}
