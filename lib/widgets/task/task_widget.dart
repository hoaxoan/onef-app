import 'package:flutter/material.dart';
import 'package:onef/models/task_widget.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';

class OFTaskWidget extends StatelessWidget {
  final TaskWidget taskWidget;
  final ValueChanged<TaskWidget> onView;

  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  OFTaskWidget({this.taskWidget, this.onView});

  String getTitle() {
    if (taskWidget.state == TaskWidgetState.Today) {
      return _localizationService.task__today;
    } else if (taskWidget.state == TaskWidgetState.Scheduled) {
      return _localizationService.task__scheduled;
    } else if (taskWidget.state == TaskWidgetState.Flagged) {
      return _localizationService.task__flagged;
    } else {
      return _localizationService.task__all;
    }
  }

  IconData getIcon() {
    if (taskWidget.state == TaskWidgetState.Today) {
      return Icons.date_range;
    } else if (taskWidget.state == TaskWidgetState.Scheduled) {
      return Icons.schedule;
    } else if (taskWidget.state == TaskWidgetState.Flagged) {
      return Icons.flag;
    } else {
      return Icons.archive;
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _localizationService = provider.localizationService;
    _themeService = provider.themeService;
    _themeValueParserService = provider.themeValueParserService;

    return OFShadowedBox(
      borderRadius: BorderRadius.circular(12.0),
      spreadRadius: -16.0,
      blurRadius: 24.0,
      shadowOffset: Offset(0.0, 0.0),
      color: taskWidget.color != null
          ? Color(taskWidget.color.color)
          : Color.fromRGBO(89, 157, 166, 1),
      child: InkWell(
        onTap: () => onView(taskWidget),
        child: new Stack(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Icon(
                  getIcon(),
                  size: 32,
                  color: Colors.white,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 8,
                  top: 4,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: OFText(
                      taskWidget.qty != null ? taskWidget.qty.toString() : "0",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).primaryTextTheme.title.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.white,
                          )),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(
                top: 0, bottom: 12.0, left: 16.0, right: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OFText(getTitle(),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .title
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
