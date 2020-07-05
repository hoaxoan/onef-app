import 'package:onef/models/sub_task.dart';

class SubTasksList {
  final List<SubTask> subTasks;

  SubTasksList({
    this.subTasks,
  });

  factory SubTasksList.fromJson(List<dynamic> parsedJson) {
    List<SubTask> subTasks =
        parsedJson.map((subTaskJson) => SubTask.fromJSON(subTaskJson)).toList();

    return new SubTasksList(
      subTasks: subTasks,
    );
  }
}
