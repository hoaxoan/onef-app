import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/widgets/theming/highlighted_color_container.dart';

class OFRoundedBottomSheet extends StatelessWidget {
  final Widget child;

  const OFRoundedBottomSheet({@required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(10);

    return OFHighlightedColorContainer(
        mainAxisSize: MainAxisSize.min,
        child: child,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: borderRadius, topLeft: borderRadius)));
  }
}
