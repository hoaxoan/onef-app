import 'package:flutter/material.dart';
import 'package:onef/widgets/drawable.dart';

/// Mood
class OFStoryMood extends StatelessWidget {
  final double size;
  final IconData icon;

  const OFStoryMood({
    Key key,
    this.size = 96.0,
    this.icon = D.happy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: Colors.white.withOpacity(0.5),
      size: size,
    );
  }
}
