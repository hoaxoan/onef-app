import 'package:flutter/material.dart';

class OFClose extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const OFClose({
    Key key,
    this.color = Colors.white30,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: IconButton(
          padding: EdgeInsets.only(right: 32.0, top: 16.0),
          icon: Icon(
            Icons.close,
            color: color,
            size: 36.0,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
