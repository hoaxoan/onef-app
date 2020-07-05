import 'package:flutter/material.dart';
import 'package:onef/widgets/icon.dart';

class OFIconButton extends StatelessWidget {
  final OFIconData iconData;
  final OFIconSize size;
  final double customSize;
  final Color color;
  final OFIconThemeColor themeColor;
  final VoidCallback onPressed;

  OFIconButton(this.iconData,
      {this.size,
      this.customSize,
      this.color,
      this.themeColor,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: OFIcon(
        iconData,
        size: size,
        customSize: customSize,
        color: color,
        themeColor: themeColor,
      ),
    );
  }
}
