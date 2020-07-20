import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/pages/home/pages/modals/post_comment/post_comment_reply_expanded.dart';
import 'package:onef/pages/home/pages/modals/post_comment/post_commenter_expanded.dart';
import 'package:onef/pages/home/pages/modals/save_post/create_post.dart';
import 'package:onef/pages/home/pages/task/widgets/create_task.dart';
import 'package:onef/widgets/new_post_data_uploader.dart';
import 'package:onef/widgets/new_task_data_uploader.dart';

import 'localization.dart';

class ModalService {
  LocalizationService localizationService;

  void setLocalizationService(localizationService) {
    this.localizationService = localizationService;
  }

  Future<OFNewPostData> openCreatePost(
      {@required BuildContext context,
        Community community,
        String text,
        File image,
        File video}) async {
    OFNewPostData createPostData =
    await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<OFNewPostData>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Material(
            child: OFSavePostModal(
              community: community,
              text: text,
              image: image,
              video: video,
            ),
          );
        }));

    return createPostData;
  }

  Future<Post> openEditPost(
      {@required BuildContext context, @required Post post}) async {
    Post editedPost = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Post>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Material(
            child: OFSavePostModal(
              post: post,
            ),
          );
        }));

    return editedPost;
  }

  Future<PostComment> openExpandedCommenter(
      {@required BuildContext context,
        @required PostComment postComment,
        @required Post post}) async {
    PostComment editedComment = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<PostComment>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Material(
            child: OFPostCommenterExpandedModal(
              post: post,
              postComment: postComment,
            ),
          );
        }));
    return editedComment;
  }

  Future<PostComment> openExpandedReplyCommenter(
      {@required BuildContext context,
        @required PostComment postComment,
        @required Post post,
        @required Function(PostComment) onReplyAdded,
        @required Function(PostComment) onReplyDeleted}) async {
    PostComment replyComment = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<PostComment>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Material(
            child: OFPostCommentReplyExpandedModal(
                post: post,
                postComment: postComment,
                onReplyAdded: onReplyAdded,
                onReplyDeleted: onReplyDeleted),
          );
        }));
    return replyComment;
  }

  Future<OFNewTaskData> openCreateTask({@required BuildContext context}) async {
    OFNewTaskData createTaskData =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<OFNewTaskData>(
                fullscreenDialog: false,
                builder: (BuildContext context) {
                  return Material(
                    child: OFSaveTaskModal(),
                  );
                }));

    return createTaskData;
  }
}
