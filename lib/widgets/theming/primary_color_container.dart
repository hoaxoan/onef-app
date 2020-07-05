import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFPrimaryColorContainer extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final MainAxisSize mainAxisSize;

  const OFPrimaryColorContainer(
      {Key key,
      this.child,
      this.decoration,
      this.mainAxisSize = MainAxisSize.max})
      : super(key: key);

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

          Widget container = DecoratedBox(
            decoration: BoxDecoration(
                color: themeValueParserService.parseColor(theme.primaryColor),
                borderRadius: decoration?.borderRadius),
            child: child,
          );

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
