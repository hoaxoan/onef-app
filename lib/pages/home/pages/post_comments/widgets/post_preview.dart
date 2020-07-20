import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/widgets/post/widgets/post_actions/post_actions.dart';
import 'package:onef/widgets/post/widgets/post_body/post_body.dart';
import 'package:onef/widgets/post/widgets/post_circles.dart';
import 'package:onef/widgets/post/widgets/post_comments/post_comments.dart';
import 'package:onef/widgets/post/widgets/post_divider.dart';
import 'package:onef/widgets/post/widgets/post_header/post_header.dart';
import 'package:onef/widgets/post/widgets/post_reactions.dart';

class OFPostPreview extends StatelessWidget {
  final Post post;
  final Function(Post) onPostDeleted;
  final VoidCallback focusCommentInput;
  final bool showViewAllCommentsAction;

  OFPostPreview(
      {this.post,
      this.onPostDeleted,
      this.focusCommentInput,
      this.showViewAllCommentsAction = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OFPostHeader(
          post: this.post,
          onPostDeleted: this.onPostDeleted,
        ),
        OFPostBody(this.post),
        const SizedBox(
          height: 20,
        ),
        OFPostReactions(this.post),
        const SizedBox(
          height: 10,
        ),
        OFPostCircles(this.post),
        showViewAllCommentsAction == true
            ? OFPostComments(
                this.post,
              )
            : SizedBox(),
        OFPostActions(
          this.post,
          onWantsToCommentPost: this.focusCommentInput,
        ),
        const SizedBox(
          height: 16,
        ),
        OFPostDivider()
      ],
    );
  }
}
