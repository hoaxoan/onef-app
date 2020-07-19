import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFRemainingPostCharacters extends StatelessWidget {
  final int maxCharacters;
  final int currentCharacters;

  const OFRemainingPostCharacters(
      {Key key, @required this.maxCharacters, @required this.currentCharacters})
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

          int remainingCharacters = maxCharacters - currentCharacters;
          bool exceededMaxCharacters = remainingCharacters < 0;

          return Text(
            remainingCharacters.toString(),
            style: TextStyle(
                fontSize: 12.0,
                color: exceededMaxCharacters
                    ? themeValueParserService.parseColor(theme.dangerColor)
                    : themeValueParserService
                        .parseColor(theme.primaryTextColor),
                fontWeight: exceededMaxCharacters
                    ? FontWeight.bold
                    : FontWeight.normal),
          );
        });
  }
}
