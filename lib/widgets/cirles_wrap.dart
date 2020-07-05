import 'package:flutter/material.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/widgets/circle_color_preview.dart';
import 'package:onef/widgets/theming/text.dart';

class OFCirclesWrap extends StatelessWidget {
  final List<Circle> circles;
  final Widget leading;
  final OFTextSize textSize;
  final OFCircleColorPreviewSize circlePreviewSize;

  const OFCirclesWrap(
      {Key key,
      this.circles,
      this.leading,
      this.textSize = OFTextSize.medium,
      this.circlePreviewSize = OFCircleColorPreviewSize.small})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> connectionItems = [];

    if (leading != null) connectionItems.add(leading);

    circles.forEach((Circle circle) {
      connectionItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OFCircleColorPreview(
            circle,
            size: circlePreviewSize,
          ),
          const SizedBox(
            width: 5,
          ),
          OFText(
            circle.name,
            size: textSize,
          )
        ],
      ));
    });

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: connectionItems,
    );
  }
}
