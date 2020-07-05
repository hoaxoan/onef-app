import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/theming/text.dart';

/// A navigation bar that uses the current theme colours
class OFThemedNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Widget leading;
  final String title;
  final Widget trailing;
  final String previousPageTitle;
  final Widget middle;

  OFThemedNavigationBar({
    this.leading,
    this.previousPageTitle,
    this.title,
    this.trailing,
    this.middle,
  });

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParserService = provider.themeValueParserService;

    return StreamBuilder(
      stream: themeService.themeChange,
      initialData: themeService.getActiveTheme(),
      builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
        var theme = snapshot.data;

        Color actionsForegroundColor = themeValueParserService
            .parseGradient(theme.primaryAccentColor)
            .colors[1];

        return CupertinoNavigationBar(
          border: null,
          actionsForegroundColor: actionsForegroundColor != null
              ? actionsForegroundColor
              : Colors.black,
          middle: middle ??
              (title != null
                  ? OFText(
                      title,
                    )
                  : const SizedBox()),
          transitionBetweenRoutes: false,
          backgroundColor:
              themeValueParserService.parseColor(theme.primaryColor),
          trailing: trailing,
          leading: leading,
        );
      },
    );
  }

  /// True if the navigation bar's background color has no transparency.
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
