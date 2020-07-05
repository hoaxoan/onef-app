import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFHighlightedColorContainer extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final MainAxisSize mainAxisSize;

  const OFHighlightedColorContainer(
      {Key key,
      this.child,
      this.decoration,
      this.mainAxisSize = MainAxisSize.max})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var oneFProvider = OneFProvider.of(context);
    var themeService = oneFProvider.themeService;
    var themeValueParserService = oneFProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;

          var primaryColor =
              themeValueParserService.parseColor(theme.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          final highlightedColor = isDarkPrimaryColor
              ? Color.fromARGB(30, 255, 255, 255)
              : Color.fromARGB(10, 0, 0, 0);

          Widget container = DecoratedBox(
              decoration: BoxDecoration(
                  color: themeValueParserService.parseColor(theme.primaryColor),
                  borderRadius: decoration?.borderRadius),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: highlightedColor,
                    borderRadius: decoration?.borderRadius),
                child: child,
              ));

          if (mainAxisSize == MainAxisSize.min) {
            return container;
          }

          return Column(
            mainAxisSize: mainAxisSize,
            children: <Widget>[Expanded(child: container)],
          );
        });
  }
}
