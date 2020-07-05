import 'dart:math';

import 'package:flutter/material.dart';

class OFActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OFActionButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: Random().toString(),
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? null : Colors.white,
      child: CustomPaint(
        child: Container(),
        foregroundPainter: OFFloatingPainter(),
      ),
      onPressed: onPressed,
    );
  }
}

class OFFloatingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint amberPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 5;

    Paint greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5;

    Paint bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5;

    Paint redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5;

    canvas.drawLine(Offset(size.width * 0.27, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.5), amberPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width * 0.5, size.height - (size.height * 0.27)),
        greenPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width - (size.width * 0.27), size.height * 0.5), bluePaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.5),
        Offset(size.width * 0.5, size.height * 0.27), redPaint);
  }

  @override
  bool shouldRepaint(OFFloatingPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(OFFloatingPainter oldDelegate) => false;
}
