import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFText extends StatelessWidget {
  static double getTextSize(OFTextSize size) {
    double fontSize;

    switch (size) {
      case OFTextSize.extraSmall:
        fontSize = 10;
        break;
      case OFTextSize.small:
        fontSize = 12;
        break;
      case OFTextSize.mediumSecondary:
        fontSize = 14;
        break;
      case OFTextSize.medium:
        fontSize = 16;
        break;
      case OFTextSize.large:
        fontSize = 17;
        break;
      case OFTextSize.extraLarge:
        fontSize = 30;
    }

    return fontSize;
  }

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int maxLines;
  final OFTextSize size;

  const OFText(this.text,
      {this.style,
      this.textAlign,
      this.overflow,
      this.maxLines,
      this.size = OFTextSize.medium});

  @override
  Widget build(BuildContext context) {
    var oneFProvider = OneFProvider.of(context);
    var themeService = oneFProvider.themeService;
    var themeValueParserService = oneFProvider.themeValueParserService;

    double fontSize = getTextSize(size);

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;

          TextStyle themedTextStyle = TextStyle(
              color: themeValueParserService.parseColor(theme.primaryTextColor),
              fontFamily: 'GoogleSans',
              fontFamilyFallback: ['GoogleSans'],
              fontSize: (style != null && style.fontSize != null)
                  ? style.fontSize
                  : fontSize);

          if (style != null) {
            themedTextStyle = themedTextStyle.merge(style);
          }

          return Text(
            text,
            style: themedTextStyle,
            overflow: overflow,
            maxLines: maxLines,
            textAlign: textAlign,
          );
        });
  }
}

enum OFTextSize {
  extraSmall,
  small,
  mediumSecondary,
  medium,
  large,
  extraLarge
}
