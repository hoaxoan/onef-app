import 'package:flutter/material.dart';
import 'package:onef/models/circle.dart';
import 'package:pigment/pigment.dart';

class OFCircleColorPreview extends StatelessWidget {
  final Circle circle;
  final OFCircleColorPreviewSize size;
  static double circleSizeLarge = 45;
  static double circleSizeMedium = 25;
  static double circleSizeSmall = 15;
  static double circleSizeExtraSmall = 10;

  OFCircleColorPreview(this.circle,
      {this.size = OFCircleColorPreviewSize.medium});

  @override
  Widget build(BuildContext context) {
    double circleSize = _getCircleSize(size);

    return Container(
      height: circleSize,
      width: circleSize,
      decoration: BoxDecoration(
          color: Pigment.fromString(circle.color),
          border: Border.all(color: Color.fromARGB(10, 0, 0, 0), width: 3),
          borderRadius: BorderRadius.circular(50)),
    );
  }

  double _getCircleSize(OFCircleColorPreviewSize size) {
    double circleSize;

    switch (size) {
      case OFCircleColorPreviewSize.large:
        circleSize = circleSizeLarge;
        break;
      case OFCircleColorPreviewSize.medium:
        circleSize = circleSizeMedium;
        break;
      case OFCircleColorPreviewSize.small:
        circleSize = circleSizeSmall;
        break;
      case OFCircleColorPreviewSize.extraSmall:
        circleSize = circleSizeExtraSmall;
        break;
    }

    return circleSize;
  }
}

enum OFCircleColorPreviewSize { small, medium, large, extraSmall }
