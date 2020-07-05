import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/theming/text.dart';

class OFSecondaryText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final OFTextSize size;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final int maxLines;

  const OFSecondaryText(this.text,
      {this.style, this.size, this.overflow, this.textAlign, this.maxLines});

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

          TextStyle finalStyle = style;
          TextStyle themedTextStyle = TextStyle(
              color:
                  themeValueParserService.parseColor(theme.secondaryTextColor));

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
            textAlign: textAlign,
          );
        });
  }
}
