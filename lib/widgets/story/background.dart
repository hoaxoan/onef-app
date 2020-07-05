import 'dart:math';

import 'package:flutter/material.dart';

class OFBackground extends StatelessWidget {
  const OFBackground({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: new Random(new DateTime.now().millisecondsSinceEpoch).toString(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(134, 217, 164, 1), Color.fromRGBO(100, 172, 165, 1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
