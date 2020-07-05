import 'package:flutter/material.dart';
import 'package:onef/models/sub_task.dart';
import 'package:onef/models/sub_tasks_list.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/task/sub_task.dart';
import 'package:onef/widgets/task/task.dart';
import 'package:onef/widgets/theming/text.dart';

class OFTaskDetailPage extends StatefulWidget {
  final TaskList taskList;
  final Task task;
  OFTaskDetailPage({this.taskList, this.task});
  @override
  State<OFTaskDetailPage> createState() {
    return _OFTaskDetailPageState();
  }
}

class _OFTaskDetailPageState extends State<OFTaskDetailPage> {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  bool _needsBootstrap;

  TaskList taskList;
  Task task;

  TextEditingController _detailsController;

  Future _getTask() async {
    taskList = widget.taskList;
    task = widget.task;

    if (task == null) return;
    setState(() {
      if (task.description != null) {
        _detailsController = TextEditingController(
          text: task.description,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getTask();

    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _bootstrap() async {}

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context, true);
          },
        ),
        title: OFText(
          taskList.name,
          style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              Navigator.pop(context, false);
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.0,
              ),
              child: Icon(
                D.deleteBold,
                color: Colors.black54,
                size: 24,
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.grey),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                ),
                child: OFTask(taskList: taskList, task: task),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                ),
                child:
                    Column(children: _buildSubTaskList(context, task.subTasks)),
              ),
              ListTile(
                leading: Icon(
                  Icons.short_text,
                  size: 28,
                  color: Colors.grey,
                ),
                title: TextField(
                  controller: _detailsController,
                  onChanged: (value) {
                    setState(() {
                      task.description = value;
                    });
                  },
                  style: Theme.of(context)
                      .textTheme
                      .headline
                      .copyWith(fontSize: 18.0, fontFamily: "GoogleSans"),
                  maxLines: 1,
                  maxLengthEnforced: false,
                  decoration: InputDecoration(
                    hintText: "Note",
                    border: InputBorder.none,
                    hintStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(fontSize: 18.0, fontFamily: "GoogleSans"),
                  ),
                ),
              ),
              /* ListTile(
                leading: Icon(
                  Icons.event_available,
                  size: 28,
                  color: Colors.grey,
                ),
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: task?.date ?? DateTime.now(),
                    firstDate: (task?.date ?? DateTime.now()).subtract(Duration(
                      days: 30,
                    )),
                    lastDate:
                        (task?.date ?? DateTime.now()).add(Duration(days: 365)),
                  ).then((value) {
                    if (value == null) return;
                    print("Date: ${value.toIso8601String()}");
                    setState(() {
                      task.date = value;
                    });
                  }).catchError((error) {
                    print(error.toString());
                  });
                },
                title: task?.date != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DateViewWidget(
                            date: task.date,
                            onClose: () {
                              setState(() {
                                task.date = null;
                              });
                            },
                          ),
                        ],
                      )
                    : Text(messages.task_date_hint,
                        style: Theme.of(context).textTheme.headline.copyWith(
                            fontSize: 18.0, fontFamily: "GoogleSans")),
              ),*/
            ],
          ),
        ),
      )),
    );
  }

  List<Widget> _buildSubTaskList(
      BuildContext context, SubTasksList subTasksList) {
    List<Widget> widgets = [];
    widgets = subTasksList == null ||
            subTasksList.subTasks == null ||
            subTasksList.subTasks.length == 0
        ? []
        : subTasksList.subTasks
            .map<Widget>((SubTask subTask) => OFSubTask(
                taskList: taskList,
                subTask: subTask,
                onRemove: (SubTask subTask) {}))
            .toList();

    widgets
      ..add(Row(
        children: <Widget>[
          Icon(
            Icons.add,
            size: 28,
            color: Colors.blue,
          ),
          RaisedButton(
            highlightElevation: 0.0,
            elevation: 0.0,
            splashColor: Colors.blue,
            color: Colors.white,
            onPressed: () {
              setState(() {
                if (task.subTasks == null)
                  task.subTasks =
                      new SubTasksList(subTasks: new List<SubTask>());

                task.subTasks.subTasks.add(new SubTask(
                  id: DateTime.now().millisecondsSinceEpoch,
                ));
              });
            },
            child: OFText("Next Step",
                style: Theme.of(context).textTheme.headline.copyWith(
                      color: Colors.blue,
                      fontSize: 18.0,
                    )),
          ),
        ],
      ));

    return widgets;
  }
}
