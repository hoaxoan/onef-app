import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_home.dart';
import 'package:onef/widgets/task/home_task.dart';
import 'package:onef/widgets/theming/text.dart';

class OFHomeTaskList extends StatelessWidget {
  final TaskHome taskHome;
  final ValueChanged<Task> onView;

  OFHomeTaskList({this.taskHome, this.onView});
  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return SliverStickyHeader(
      overlapsContent: true,
      header: _OFTaskHomeListHeader(taskHome: taskHome),
      sliver: SliverPadding(
        padding: const EdgeInsets.only(left: 60, bottom: 12),
        sliver: OFHomeTask(
          tasks: taskHome.tasks,
          onView: onView,
        ),
      ),
    );
  }
}

class _OFTaskHomeListHeader extends StatelessWidget {
  const _OFTaskHomeListHeader({
    Key key,
    this.taskHome,
  }) : super(key: key);

  final TaskHome taskHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 52.0,
          width: 52.0,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OFText(
                    "9",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      children: <Widget>[
                        OFText(
                          "30",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        OFText(
                          "PM",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
