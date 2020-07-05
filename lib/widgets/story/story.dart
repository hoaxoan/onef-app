import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/story/history_story_card.dart';
import 'package:onef/widgets/story/story_action/story_actions.dart';
import 'file:///G:/reaction/onef/lib/widgets/story/story_body/story_body.dart';
import 'file:///G:/reaction/onef/lib/widgets/story/story_body/story_body_text.dart';
import 'package:onef/widgets/story/story_date.dart';
import 'package:onef/widgets/story/story_divider.dart';
import 'package:onef/widgets/story/story_mood.dart';
import 'package:onef/widgets/story/story_title.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStory extends StatelessWidget {
  final Story story;
  final ValueChanged<Story> onStoryDeleted;
  final ValueChanged<Story> onStoryIsInView;
  final OnTextExpandedChange onTextExpandedChange;
  final String inViewId;
  final OFStoryDisplayContext displayContext;

  const OFStory(this.story,
      {Key key,
        @required this.onStoryDeleted,
        this.onStoryIsInView,
        this.onTextExpandedChange,
        this.inViewId,
        this.displayContext = OFStoryDisplayContext.timelinePosts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String storyInViewId;
    if (this.displayContext == OFStoryDisplayContext.topPosts)
      storyInViewId = story.id.toString();

    _bootstrap(context, storyInViewId);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Hero(
          tag: '${story.id}-${story.title}-hero' +
              new Random(new DateTime.now().millisecondsSinceEpoch)
                  .toString(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
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
        OFStoryBody(story,
            onTextExpandedChange: onTextExpandedChange, inViewId: inViewId),
        OFStoryActions(
          story,
        ),
        const SizedBox(
          height: 16,
        ),
        OFStoryDivider()
      ]
    );
    /*
    return GestureDetector(
      onTap: () => onStoryIsInView(story),
      child: OFShadowedBox(
        borderRadius: BorderRadius.circular(12.0),
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
                borderRadius: BorderRadius.circular(12.0),
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
              child: OFFavorite(story: story),
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
    );*/
  }

  void _bootstrap(BuildContext context, String postInViewId) {
  }
}

enum OFStoryDisplayContext {
  timelinePosts,
  topPosts,
  communityPosts,
  foreignProfilePosts,
  ownProfilePosts
}
