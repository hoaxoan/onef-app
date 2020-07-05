import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFHighlightedBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const OFHighlightedBox({Key key, this.child, this.padding, this.borderRadius})
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

          return Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: highlightedColor,
            ),
            child: child,
          );
        });
  }
}
