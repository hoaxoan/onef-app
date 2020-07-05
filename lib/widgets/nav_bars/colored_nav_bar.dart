import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/theme_value_parser.dart';

/// A coloured navigation bar, used in communities.
class OFColoredNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Color color;
  final Color textColor;
  final Color actionsColor;
  final Widget leading;
  final Widget middle;
  final Widget trailing;
  final String title;

  const OFColoredNavBar(
      {Key key,
      @required this.color,
      this.leading,
      this.trailing,
      this.title,
      this.textColor,
      this.actionsColor,
      this.middle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeValueParserService = OneFProvider.of(context).themeValueParserService;
    bool isDarkColor = themeValueParserService.isDarkColor(color);
    Color finalActionsColor =
        actionsColor ?? (isDarkColor ? Colors.white : Colors.black);

    return CupertinoNavigationBar(
        border: null,
        leading: leading,
        actionsForegroundColor: finalActionsColor,
        middle: middle ??
            Text(
              title,
              style: TextStyle(color: textColor ?? finalActionsColor),
            ),
        transitionBetweenRoutes: false,
        backgroundColor: color,
        trailing: trailing);
  }

  @override
  bool get fullObstruction => true;

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
