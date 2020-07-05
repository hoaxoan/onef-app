import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';

class OFTask extends StatefulWidget {
  final TaskList taskList;
  final Task task;
  final ValueChanged<Task> onCompleted;
  final ValueChanged<Task> onFlagged;
  OFTask({this.taskList, this.task, this.onCompleted, this.onFlagged});

  @override
  _OFTaskState createState() => _OFTaskState();
}

class _OFTaskState extends State<OFTask> {
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  TextFormField _titleInput;
  TextEditingController _titleController;
  TextDecoration _textFieldDecoration;
  Color _textFieldColor;
  bool _textFieldEnable;
  bool _textFieldFocus;

  TaskList taskList;
  Task task;

  @override
  void initState() {
    taskList = widget.taskList;
    task = widget.task;

    if (task == null) return;
    setState(() {
      if (task.name != null) {
        _titleController = TextEditingController(
          text: task.name != null ? task.name : "",
        );
      }

      if (task.isCompleted != null && task.isCompleted) {
        _textFieldFocus = false;
        _textFieldDecoration = TextDecoration.lineThrough;
        _textFieldColor = Colors.grey;
        _textFieldEnable = false;
      } else {
        _textFieldFocus = true;
        _textFieldDecoration = TextDecoration.none;
        _textFieldColor = Colors.black;
        _textFieldEnable = true;
      }

      _titleInput = TextFormField(
          onChanged: (value) {
            setState(() {
              task.name = value;
            });
          },
          autofocus: _textFieldFocus,
          controller: _titleController,
          maxLines: 1,
          maxLengthEnforced: false,
          cursorColor: Colors.black,
          enabled: _textFieldEnable,
          style: TextStyle(
              decoration: _textFieldDecoration,
              color: _textFieldColor,
              fontSize: 32.0,
              fontFamily: "GoogleSans",
              fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: "Name",
              border: InputBorder.none,
              hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                  fontFamily: "GoogleSans")));
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _localizationService = provider.localizationService;
    _themeService = provider.themeService;
    _themeValueParserService = provider.themeValueParserService;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 0.0, bottom: 0.0),
          child: InkWell(
            onTap: () async {
              setState(() {
                if (task.isCompleted == null) {
                  task.isCompleted = true;
                  task.active = true;
                } else {
                  task.isCompleted = !task.isCompleted;
                  task.active = !task.active;
                }

                if (task.isCompleted) {
                  _textFieldFocus = false;
                  _textFieldDecoration = TextDecoration.lineThrough;
                  _textFieldColor = Colors.grey;
                  _textFieldEnable = false;
                } else {
                  _textFieldFocus = true;
                  _textFieldDecoration = TextDecoration.none;
                  _textFieldColor = Colors.black;
                  _textFieldEnable = true;
                }

                _titleInput = TextFormField(
                    onChanged: (value) {
                      setState(() {
                        task.name = value;
                      });
                    },
                    autofocus: _textFieldFocus,
                    controller: _titleController,
                    maxLines: 1,
                    maxLengthEnforced: false,
                    cursorColor: Colors.black,
                    enabled: _textFieldEnable,
                    style: TextStyle(
                        decoration: _textFieldDecoration,
                        color: _textFieldColor,
                        fontSize: 32.0,
                        fontFamily: "GoogleSans",
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        hintText: "Name",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 18.0,
                            fontFamily: "GoogleSans")));
              });

              if (task.isCompleted != null && task.isCompleted) {}
              widget.onCompleted(task);
            },
            child: task.isCompleted != null && task.isCompleted
                ? Icon(
                    Icons.check_circle,
                    size: 32,
                    color: taskList.color != null
                        ? Color(taskList.color.color)
                        : Colors.blue,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    size: 32,
                    color: Colors.grey,
                  ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 16.0, bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_titleInput],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.only(top: 4.0),
              icon: task.isFlagged != null && task.isFlagged
                  ? Icon(
                      Icons.star,
                      size: 28.0,
                      color: taskList.color != null
                          ? Color(taskList.color.color)
                          : Colors.blue,
                    )
                  : Icon(
                      Icons.star_border,
                      size: 28.0,
                    ),
              onPressed: () async {
                setState(() {
                  if (task.isFlagged == null)
                    task.isFlagged = true;
                  else
                    task.isFlagged = !task.isFlagged;
                });

                widget.onFlagged(task);
              },
            ),
          ],
        ),
      ],
    );
  }
}
