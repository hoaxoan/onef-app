import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/story/story_date.dart';
import 'package:onef/widgets/story/story_mood.dart';
import 'package:onef/widgets/story/story_title.dart';

const kCardRadius = 12.0;

/// Story card
class OFHistoryStoryCard extends StatelessWidget {
  final Story story;
  final ValueChanged<Story> navigateToDetail;
  final ValueChanged<Story> favorite;

  const OFHistoryStoryCard(
      {Key key,
        @required this.story,
        @required this.navigateToDetail,
        @required this.favorite})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToDetail(story),
      child: OFShadowedBox(
        borderRadius: BorderRadius.circular(kCardRadius),
        spreadRadius: -16.0,
        blurRadius: 24.0,
        shadowOffset: Offset(0.0, 24.0),
        margin: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          bottom: 64,
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Hero(
              tag: '${story.id}-${story.title}-hero' +
                  new Random(new DateTime.now().millisecondsSinceEpoch)
                      .toString(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardRadius),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromRGBO(134, 217, 164, 1), Color.fromRGBO(100, 172, 165, 1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24.0,
              top: 24.0,
              child: OFStoryDate(storyDate: story.created),
            ),
            Positioned(
              right: 24.0,
              top: 12.0,
              child: OFFavorite(story: story, favorite: favorite),
            ),
            Positioned(
              left: 24.0,
              bottom: 24.0,
              child: OFStoryTitle(title: story.title),
            ),
            Positioned(
              right: -16.0,
              bottom: 24.0,
              child: story.mood != null
                  ? OFStoryMood(
                  icon: new IconData(int.parse(story.mood.code),
                      fontFamily: 'ReflectlyIcons'))
                  : OFStoryMood(),
            ),
          ],
        ),
      ),
    );
  }
}

///
/// Favorite
///
class OFFavorite extends StatelessWidget {
  final Story story;
  final ValueChanged<Story> favorite;
  const OFFavorite({Key key, @required this.story, @required this.favorite})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: story.isFavorite != null && story.isFavorite
          ? Icon(
        D.love2,
        color: Colors.pinkAccent,
        size: 32.0,
      )
          : Icon(
        D.favorite,
        color: Colors.white,
        size: 32.0,
      ),
      onPressed: () => favorite(story),
    );
  }
}
