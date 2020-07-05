import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFDivider extends StatelessWidget {
  const OFDivider();

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

          return SizedBox(
            height: 16.0,
            child: Center(
              child: Container(
                height: 0.0,
                margin: EdgeInsetsDirectional.only(start: 0),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: themeValueParserService
                        .parseColor(theme.secondaryTextColor),
                    width: 0.5,
                  )),
                ),
              ),
            ),
          );
        });
  }
}
