import 'package:flutter/material.dart';

class OFProgressIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const OFProgressIndicator({Key key, this.color, this.size = 20.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: size,
        maxWidth: size,
      ),
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
