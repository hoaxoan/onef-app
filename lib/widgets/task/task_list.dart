import 'package:flutter/material.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';

class OFTaskList extends StatelessWidget {
  final TaskList taskList;
  final ValueChanged<TaskList> onView;

  OFTaskList({this.taskList, this.onView});
  @override
  Widget build(BuildContext context) {
    return buildTaskList(context, taskList);
  }

  Widget buildTaskList(BuildContext context, TaskList taskList) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return InkWell(
        onTap: () => onView(taskList),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Container(
                    child: OFShadowedBox(
                        borderRadius: BorderRadius.circular(12.0),
                        spreadRadius: -12.0,
                        blurRadius: 12.0,
                        shadowOffset: Offset(0.0, 12.0),
                        padding: const EdgeInsets.all(6.0),
                        child: MergeSemantics(
                            child: Container(
                          constraints:
                              BoxConstraints(minHeight: 42 * textScaleFactor),
                          padding:
                              EdgeInsetsDirectional.only(start: 10.0, end: 6.0),
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
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.list,
                                            size: 32,
                                            color: Colors.green,
                                          )
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
                                            child: OFText(taskList.name ?? "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 16.0)),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                OFText(
                                                  taskList.tasks == null ||
                                                          taskList.tasks.tasks
                                                              .isEmpty
                                                      ? ""
                                                      : taskList
                                                          .tasks.tasks.length
                                                          .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 16.0),
                                                ),
                                                Icon(Icons.navigate_next,
                                                    size: 32,
                                                    color: Colors.black54),
                                              ],
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
        ));
  }
}
