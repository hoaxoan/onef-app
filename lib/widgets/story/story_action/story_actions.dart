import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';

class OFStoryActions extends StatelessWidget {
  final Story story;
  final VoidCallback onWantsToCommentStory;

  OFStoryActions(this.story, {this.onWantsToCommentStory});

  @override
  Widget build(BuildContext context) {
    /*List<Widget> postActions = [
      Expanded(child: OBPostActionReact(story)),
    ];

    bool commentsEnabled = story.areCommentsEnabled ?? true;

    bool canDisableOrEnableCommentsForPost = false;

    if (!commentsEnabled) {
      var provider = OneFProvider.of(context);
      canDisableOrEnableCommentsForPost = provider.userService
          .getLoggedInUser()
          .canDisableOrEnableCommentsForPost(story);
    }

    if (commentsEnabled || canDisableOrEnableCommentsForPost) {
      postActions.addAll([
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: OBPostActionComment(
            story,
            onWantsToCommentPost: onWantsToCommentPost,
          ),
        ),
      ]);
    }*/

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              //children: postActions,
            )
          ],
        ));
  }
}
