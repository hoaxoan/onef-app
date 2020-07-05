import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/post/widgets/post_actions/widgets/post_action_comment.dart';
import 'package:onef/widgets/post/widgets/post_actions/widgets/post_action_react.dart';

class OFPostActions extends StatelessWidget {
  final Post _post;
  final VoidCallback onWantsToCommentPost;

  OFPostActions(this._post, {this.onWantsToCommentPost});

  @override
  Widget build(BuildContext context) {
    List<Widget> postActions = [
      Expanded(child: OFPostActionReact(_post)),
    ];

    bool commentsEnabled = _post.areCommentsEnabled ?? true;

    bool canDisableOrEnableCommentsForPost = false;

    if (!commentsEnabled) {
      var provider = OneFProvider.of(context);
      canDisableOrEnableCommentsForPost = provider.userService
          .getLoggedInUser()
          .canDisableOrEnableCommentsForPost(_post);
    }

    if (commentsEnabled || canDisableOrEnableCommentsForPost) {
      postActions.addAll([
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: OFPostActionComment(
            _post,
            onWantsToCommentPost: onWantsToCommentPost,
          ),
        ),
      ]);
    }

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: postActions,
            )
          ],
        ));
  }
}
