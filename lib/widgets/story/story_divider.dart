import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:tinycolor/tinycolor.dart';

class OFStoryDivider extends StatelessWidget {
  const OFStoryDivider();

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

          Color color = themeValueParserService.parseColor(theme.primaryColor);

          TinyColor modifiedColor = themeValueParserService.isDarkColor(color)
              ? TinyColor(color).lighten(30)
              : TinyColor(color).darken(30);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: modifiedColor.color,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                height: 1,
              ),
            ),
          );
        });
  }
}
