import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/avatars/avatar.dart';

class OFLetterAvatar extends StatelessWidget {
  final OFAvatarSize size;
  final Color color;
  final Color labelColor;
  final String letter;
  final VoidCallback onPressed;
  final double borderRadius;
  final double customSize;

  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 24.0;
  static const double fontSizeLarge = 40.0;
  static const double fontSizeExtraLarge = 60.0;

  const OFLetterAvatar(
      {Key key,
      this.size = OFAvatarSize.medium,
      @required this.color,
      this.labelColor,
      @required this.letter,
      this.onPressed,
      this.borderRadius,
      this.customSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeValueParserService =
        OneFProvider.of(context).themeValueParserService;
    double avatarSize = customSize ?? OFAvatar.getAvatarSize(size);
    double fontSize = getAvatarFontSize(size);
    Color finalLabelColor = labelColor != null
        ? labelColor
        : (themeValueParserService.isDarkColor(color)
            ? Colors.white
            : Colors.black);

    Widget avatar = Container(
      height: avatarSize,
      width: avatarSize,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
              borderRadius ?? OFAvatar.avatarBorderRadius)),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
              color: finalLabelColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize),
        ),
      ),
    );

    if (onPressed != null) {
      avatar = GestureDetector(
        child: avatar,
        onTap: onPressed,
      );
    }

    return avatar;
  }

  double getAvatarFontSize(OFAvatarSize size) {
    double fontSize;

    switch (size) {
      case OFAvatarSize.extraSmall:
        fontSize = fontSizeExtraSmall;
        break;
      case OFAvatarSize.small:
        fontSize = fontSizeSmall;
        break;
      case OFAvatarSize.medium:
        fontSize = fontSizeMedium;
        break;
      case OFAvatarSize.large:
        fontSize = fontSizeLarge;
        break;
      case OFAvatarSize.extraLarge:
        fontSize = fontSizeExtraLarge;
        break;
    }

    return fontSize;
  }
}
