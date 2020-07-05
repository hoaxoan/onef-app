import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPrimaryAccentText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final OFTextSize size;
  final TextOverflow overflow;
  final int maxLines;

  OFPrimaryAccentText(this.text,
      {this.style,
      this.size,
      this.maxLines,
      this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    var themeService = OneFProvider.of(context).themeService;
    var themeValueParserService =
        OneFProvider.of(context).themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;

          TextStyle finalStyle = style;
          TextStyle themedTextStyle = TextStyle(
              foreground: Paint()
                ..shader = themeValueParserService
                    .parseGradient(theme.primaryAccentColor)
                    .createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)));

          if (finalStyle != null) {
            finalStyle = finalStyle.merge(themedTextStyle);
          } else {
            finalStyle = themedTextStyle;
          }

          return OFText(
            text,
            style: finalStyle,
            size: size,
            overflow: overflow,
            maxLines: maxLines,
          );
        });
  }
}
