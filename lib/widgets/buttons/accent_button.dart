import 'package:flutter/material.dart';
import 'package:onef/widgets/buttons/button.dart';

class OBAccentButton extends StatelessWidget {
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color textColor;
  final OFButtonSize size;
  final double minWidth;
  final EdgeInsets padding;

  const OBAccentButton(
      {@required this.child,
      @required this.onPressed,
      this.size = OFButtonSize.medium,
      this.textColor = Colors.white,
      this.icon,
      this.isDisabled = false,
      this.isLoading = false,
      this.padding,
      this.minWidth});

  @override
  Widget build(BuildContext context) {
    return OFButton(
      child: child,
      icon: icon,
      onPressed: onPressed,
      size: size,
      isDisabled: isDisabled,
      isLoading: isLoading,
      padding: padding,
      minWidth: minWidth,
      type: OFButtonType.primary,
    );
  }
}
