import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/models/tasks_list.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';

class OFHomeTask extends StatelessWidget {
  final TasksList tasks;
  final ValueChanged<Task> onView;
  final ValueChanged<Task> onDismissed;
  final ValueChanged<Task> onCompleted;
  final ValueChanged<Task> onFlagged;

  OFHomeTask(
      {this.tasks,
      this.onView,
      this.onDismissed,
      this.onCompleted,
      this.onFlagged});

  @override
  Widget build(BuildContext context) {
    if (tasks == null || tasks.tasks.isEmpty) return SliverFillRemaining();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => buildTask(context, tasks.tasks[index]),
        childCount: tasks.tasks.length,
      ),
    );
  }

  Widget buildTask(BuildContext context, Task task) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return Dismissible(
        direction: DismissDirection.startToEnd,
        key: Key(task.id.toString()),
        onDismissed: (direction) => onDismissed(task),
        background: Container(
          color: Colors.blue,
        ),
        child: InkWell(
            onTap: () => onView(task),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                        child: OFShadowedBox(
                            borderRadius: BorderRadius.circular(12.0),
                            spreadRadius: -12.0,
                            blurRadius: 12.0,
                            shadowOffset: Offset(0.0, 12.0),
                            padding: const EdgeInsets.all(6.0),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 2.0),
                            child: MergeSemantics(
                                child: Container(
                              constraints: BoxConstraints(
                                  minHeight: 42 * textScaleFactor),
                              padding: EdgeInsetsDirectional.only(
                                  start: 10.0, end: 6.0),
                              alignment: AlignmentDirectional.centerStart,
                              child: DefaultTextStyle(
                                style: DefaultTextStyle.of(context).style,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                child: IconTheme(
                                    data: Theme.of(context).primaryIconTheme,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () => onCompleted(task),
                                                child: Icon(
                                                  Icons.radio_button_unchecked,
                                                  size: 32,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0.0),
                                                child: OFText(task?.name ?? "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 24.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                IconButton(
                                                  padding:
                                                      EdgeInsets.only(top: 0.0),
                                                  icon: task.isFlagged ==
                                                              null ||
                                                          !task.isFlagged
                                                      ? Icon(Icons.star_border,
                                                          size: 28.0,
                                                          color: Colors.black54)
                                                      : Icon(
                                                          Icons.star,
                                                          size: 28.0,
                                                          color: Colors.blue,
                                                        ),
                                                  onPressed: () =>
                                                      onFlagged(task),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            )))))
              ],
            )));
  }
}
