import 'package:flutter/material.dart';
import 'package:onef/models/sub_task.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';

class OFSubTask extends StatefulWidget {
  final TaskList taskList;
  final SubTask subTask;
  final ValueChanged<SubTask> onCompleted;
  final ValueChanged<SubTask> onRemove;
  OFSubTask({this.taskList, this.subTask, this.onCompleted, this.onRemove});

  @override
  _OFSubTaskState createState() => _OFSubTaskState();
}

class _OFSubTaskState extends State<OFSubTask> {
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
  SubTask subTask;

  @override
  void initState() {
    taskList = widget.taskList;
    subTask = widget.subTask;

    if (subTask == null) return;
    setState(() {
      if (subTask.name != null) {
        _titleController = TextEditingController(
          text: subTask.name != null ? subTask.name : "",
        );
      }

      if (subTask.isCompleted != null && subTask.isCompleted) {
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
              subTask.name = value;
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
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
              fontFamily: "GoogleSans"),
          decoration: InputDecoration(
              hintText: "Name",
              border: InputBorder.none,
              hintStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
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
                if (subTask.isCompleted == null)
                  subTask.isCompleted = true;
                else
                  subTask.isCompleted = !subTask.isCompleted;

                if (subTask.isCompleted != null && subTask.isCompleted) {
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
                        subTask.name = value;
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
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: "GoogleSans"),
                    decoration: InputDecoration(
                        hintText: "Name",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                            fontFamily: "GoogleSans")));
              });

              if (subTask.isCompleted != null && subTask.isCompleted) {}
              widget.onCompleted(subTask);
            },
            child: subTask.isCompleted != null && subTask.isCompleted
                ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: taskList.color != null
                        ? Color(taskList.color.color)
                        : Colors.blue,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    size: 28,
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
              icon: Icon(Icons.close),
              onPressed: () => widget.onRemove(subTask),
            ),
          ],
        ),
      ],
    );
  }
}
