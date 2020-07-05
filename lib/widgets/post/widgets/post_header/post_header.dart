import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/post/widgets/post_header/widgets/community_post_header/community_post_header.dart';
import 'package:onef/widgets/post/widgets/post_header/widgets/user_post_header/user_post_header.dart';

class OFPostHeader extends StatelessWidget {
  final Post post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post> onPostReported;
  final bool hasActions;
  final OFPostDisplayContext displayContext;
  final Function onCommunityExcluded;
  final Function onUndoCommunityExcluded;
  final ValueChanged<Community> onPostCommunityExcludedFromProfilePosts;

  const OFPostHeader({
    Key key,
    this.onPostDeleted,
    this.post,
    this.onPostReported,
    this.onCommunityExcluded,
    this.onUndoCommunityExcluded,
    this.hasActions = true,
    this.displayContext = OFPostDisplayContext.timelinePosts,
    this.onPostCommunityExcludedFromProfilePosts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return post.isCommunityPost() &&
            displayContext != OFPostDisplayContext.communityPosts
        ? OFCommunityPostHeader(post,
            onPostDeleted: onPostDeleted,
            onPostReported: onPostReported,
            hasActions: hasActions,
            onCommunityExcluded: onCommunityExcluded,
            onUndoCommunityExcluded: onUndoCommunityExcluded,
            onPostCommunityExcludedFromProfilePosts:
                onPostCommunityExcludedFromProfilePosts,
            displayContext: displayContext)
        : OFUserPostHeader(post,
            onPostDeleted: onPostDeleted,
            onPostReported: onPostReported,
            displayContext: displayContext,
            hasActions: hasActions);
  }
}
