import 'package:flutter/material.dart';

class OFShadowedBox extends StatelessWidget {
  final double width;
  final double height;
  final Offset shadowOffset;
  final double blurRadius;
  final double spreadRadius;
  final Color shadowColor;
  final BoxShape shape;
  final Border border;
  final BorderRadius borderRadius;
  final Color color;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final Widget child;

  const OFShadowedBox({
    Key key,
    this.width,
    this.height,
    this.shadowOffset = const Offset(.0, 8.0),
    this.blurRadius = 8.0,
    this.spreadRadius = 0.0,
    this.shadowColor = Colors.black26,
    this.shape = BoxShape.rectangle,
    this.border,
    this.borderRadius,
    this.color = Colors.white,
    this.margin = const EdgeInsets.all(4.0),
    this.padding,
    this.gradient,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        border: border,
        borderRadius: borderRadius,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          )
        ],
      ),
      child: child,
    );
  }
}
