import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/widgets/theming/text.dart';

class OFHashtag extends StatelessWidget {
  final Hashtag hashtag;
  final ValueChanged<Hashtag> onPressed;
  final TextStyle textStyle;
  final String rawHashtagName;

  const OFHashtag(
      {Key key,
      @required this.hashtag,
      this.onPressed,
      this.textStyle,
      this.rawHashtagName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle finalTextStyle = TextStyle(fontWeight: FontWeight.bold);

    if (textStyle != null) finalTextStyle = finalTextStyle.merge(textStyle);

    Widget hashtagContent = OFText(
      '#' + (rawHashtagName ?? hashtag.name),
      style: finalTextStyle,
    );

    return GestureDetector(
        onTap: onPressed != null ? () => onPressed(hashtag) : null,
        child: hashtagContent);
  }
}
