import 'package:flutter/material.dart';
import 'package:onef/widgets/buttons/button.dart';

class OFFloatingActionButton extends StatelessWidget {
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color textColor;
  final OFButtonSize size;
  final double minWidth;
  final EdgeInsets padding;
  final OFButtonType type;
  final Color color;

  const OFFloatingActionButton(
      {@required this.child,
      @required this.onPressed,
      this.type,
      this.size = OFButtonSize.medium,
      this.textColor = Colors.white,
      this.icon,
      this.isDisabled = false,
      this.isLoading = false,
      this.padding,
      this.minWidth,
      this.color});

  @override
  Widget build(BuildContext context) {
    return OFButton(
      color: color,
      textColor: textColor,
      child: child,
      boxShadow: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(0.0, 1.2),
          blurRadius: 4,
        ),
      ],
      icon: icon,
      onPressed: onPressed,
      size: size,
      type: type,
      isDisabled: isDisabled,
      isLoading: isLoading,
      padding: EdgeInsets.all(0),
      minWidth: 55,
      minHeight: 55,
    );
  }
}
