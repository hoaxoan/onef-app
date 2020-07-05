import 'dart:math';
import 'package:flutter/material.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';


class OFNewStoryCard extends StatelessWidget {
  final VoidCallback navigateToNewStory;
  const OFNewStoryCard({Key key, this.navigateToNewStory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToNewStory(),
      child: OFShadowedBox(
        borderRadius: BorderRadius.circular(12.0),
        spreadRadius: -16.0,
        blurRadius: 24.0,
        shadowOffset: Offset(0.0, 24.0),
        margin: EdgeInsets.only(
          left:  8.0,
          right:  8.0,
          bottom: 64,
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          children: <Widget>[
            _OFBackground(),
            _OFAction(),
          ],
        ),
      ),
    );
  }
}

class _OFBackground extends StatelessWidget {
  const _OFBackground({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Hero(
      tag: new Random(new DateTime.now().millisecondsSinceEpoch).toString(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: [ Color.fromRGBO(134, 217, 164, 1), Color.fromRGBO(100, 172, 165, 1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _OFAction extends StatelessWidget {
  const _OFAction({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          D.favorite,
          color: Colors.white,
          size: 100.0,
        ),
        SizedBox(width: 16.0, height: 16.0),
        OFText(
          "Add new Story",
          style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 24.0),
        ),
      ],
    );
  }
}
