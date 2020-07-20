import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comment_actions.dart';
import 'package:onef/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comment_commenter_identifier.dart';
import 'package:onef/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comment_reactions.dart';
import 'package:onef/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comment_text.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/theming/secondary_text.dart';

class OFPostComment extends StatefulWidget {
  final PostComment postComment;
  final Post post;
  final ValueChanged<PostComment> onPostCommentDeleted;
  final ValueChanged<PostComment> onPostCommentReported;
  final bool showReplies;
  final bool showActions;
  final bool showReplyAction;
  final bool showReactions;
  final EdgeInsets padding;

  OFPostComment({
    @required this.post,
    @required this.postComment,
    this.onPostCommentDeleted,
    this.onPostCommentReported,
    Key key,
    this.showReplies = true,
    this.showActions = true,
    this.showReactions = true,
    this.showReplyAction = true,
    this.padding = const EdgeInsets.only(left: 15, right: 15, top: 10),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFPostCommentState();
  }
}

class OFPostCommentState extends State<OFPostComment> {
  NavigationService _navigationService;
  UserPreferencesService _userPreferencesService;
  int _repliesCount;
  List<PostComment> _replies;

  CancelableOperation _requestOperation;

  @override
  void initState() {
    super.initState();
    _repliesCount = widget.postComment.repliesCount;
    _replies = widget.postComment.getPostCommentReplies();
  }

  @override
  void dispose() {
    super.dispose();
    if (_requestOperation != null) _requestOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _navigationService = provider.navigationService;
    _userPreferencesService = provider.userPreferencesService;

    return StreamBuilder(
        key: Key('OBPostCommentTile#${widget.postComment.id}'),
        stream: widget.postComment.updateSubject,
        initialData: widget.postComment,
        builder: (BuildContext context, AsyncSnapshot<PostComment> snapshot) {
          PostComment postComment = snapshot.data;
          User commenter = postComment.commenter;

          List<Widget> commentBodyColumnItems = [
            OFPostCommentCommenterIdentifier(
              post: widget.post,
              postComment: widget.postComment,
              onUsernamePressed: _onPostCommenterPressed,
            ),
            const SizedBox(
              height: 5,
            ),
            OFPostCommentText(
              widget.postComment,
              widget.post,
              onUsernamePressed: () {
                _navigationService.navigateToUserProfile(
                    user: widget.postComment.commenter, context: context);
              },
            ),
          ];

          if (widget.showReactions) {
            commentBodyColumnItems.add(
              OFPostCommentReactions(
                postComment: widget.postComment,
                post: widget.post,
              ),
            );
          }

          if (widget.showActions) {
            commentBodyColumnItems.addAll([
              OFPostCommentActions(
                post: widget.post,
                postComment: widget.postComment,
                onReplyDeleted: _onReplyDeleted,
                onReplyAdded: _onReplyAdded,
                onPostCommentReported: widget.onPostCommentReported,
                onPostCommentDeleted: widget.onPostCommentDeleted,
                showReplyAction: widget.showReplyAction,
              ),
            ]);
          }

          if (widget.showReplies && _repliesCount != null && _repliesCount > 0)
            commentBodyColumnItems.add(_buildPostCommentReplies());

          return Column(
            children: <Widget>[
              Padding(
                padding: widget.padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    OFAvatar(
                      avatarUrl: commenter.getProfileAvatar(),
                      customSize: 35,
                      onPressed: _onPostCommenterPressed,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: commentBodyColumnItems),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _buildPostCommentReplies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.all(0),
            itemCount: widget.postComment.getPostCommentReplies().length,
            itemBuilder: (context, index) {
              PostComment reply =
                  widget.postComment.getPostCommentReplies()[index];

              return OFPostComment(
                key: Key('postCommentReply#${reply.id}'),
                padding: EdgeInsets.only(top: 15),
                postComment: reply,
                post: widget.post,
                onPostCommentDeleted: _onReplyDeleted,
              );
            }),
        _buildViewAllReplies()
      ],
    );
  }

  Widget _buildViewAllReplies() {
    if (!widget.postComment.hasReplies() ||
        (_repliesCount == _replies.length)) {
      return SizedBox();
    }

    return FlatButton(
        child: OFSecondaryText(
          'View all $_repliesCount replies',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _onWantsToViewAllReplies);
  }

  void _onWantsToViewAllReplies() {
    _navigationService.navigateToPostCommentReplies(
        post: widget.post,
        postComment: widget.postComment,
        context: context,
        onReplyDeleted: _onReplyDeleted,
        onReplyAdded: _onReplyAdded);
  }

  void _onReplyDeleted(PostComment postCommentReply) async {
    setState(() {
      _repliesCount -= 1;
      _replies.removeWhere((reply) => reply.id == postCommentReply.id);
    });
  }

  void _onReplyAdded(PostComment postCommentReply) async {
    PostCommentsSortType sortType =
        await _userPreferencesService.getPostCommentsSortType();
    setState(() {
      if (sortType == PostCommentsSortType.dec) {
        _replies.insert(0, postCommentReply);
      } else if (_repliesCount == _replies.length) {
        _replies.add(postCommentReply);
      }
      _repliesCount += 1;
    });
  }

  void _onPostCommenterPressed() {
    _navigationService.navigateToUserProfile(
        user: widget.postComment.commenter, context: context);
  }
}

typedef void OnWantsToSeeUserProfile(User user);
