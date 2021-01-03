import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/theming/text.dart';
import 'package:onef/widgets/tiles/actions/close_post_tile.dart';
import 'package:onef/widgets/tiles/actions/disable_comments_post_tile.dart';
import 'package:onef/widgets/tiles/actions/mute_post_tile.dart';
import 'package:onef/widgets/tiles/actions/report_post_tile.dart';

class OFPostActionsBottomSheet extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onPostReported;
  final OnPostDeleted onPostDeleted;
  final Function onCommunityExcluded;
  final Function onUndoCommunityExcluded;
  final OFPostDisplayContext displayContext;
  final ValueChanged<Community> onPostCommunityExcludedFromProfilePosts;

  const OFPostActionsBottomSheet(
      {Key key,
      @required this.post,
      @required this.onPostReported,
      @required this.onPostDeleted,
      this.onCommunityExcluded,
      this.onUndoCommunityExcluded,
      this.displayContext = OFPostDisplayContext.timelinePosts,
      this.onPostCommunityExcludedFromProfilePosts})
      : super(key: key);

  @override
  OFPostActionsBottomSheetState createState() {
    return OFPostActionsBottomSheetState();
  }
}

class OFPostActionsBottomSheetState extends State<OFPostActionsBottomSheet> {
  UserService _userService;
  ModalService _modalService;
  ToastService _toastService;
  LocalizationService _localizationService;
  BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _modalService = provider.modalService;
    _toastService = provider.toastService;
    _localizationService = provider.localizationService;
    _bottomSheetService = provider.bottomSheetService;

    User loggedInUser = _userService.getLoggedInUser();

    return StreamBuilder(
        stream: widget.post.updateSubject,
        initialData: widget.post,
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          Post post = snapshot.data;
          List<Widget> postActions = [];

          if (widget.displayContext == OFPostDisplayContext.topPosts) {
       /*     postActions.add(OFExcludeCommunityFromTopPostsTile(
              post: post,
              onExcludedPostCommunity: () {
                if (widget.onCommunityExcluded != null) {
                  widget.onCommunityExcluded(post.community);
                }
                _dismiss();
              },
              onUndoExcludedPostCommunity: () {
                if (widget.onUndoCommunityExcluded != null) {
                  widget.onUndoCommunityExcluded(post.community);
                }
                _dismiss();
              },
            ));*/
          } else if (widget.displayContext == OFPostDisplayContext.ownProfilePosts) {
            /*postActions.add(OFExcludeCommunityFromProfilePostsTile(
                post: post,
                onPostCommunityExcludedFromProfilePosts:
                widget.onPostCommunityExcludedFromProfilePosts));*/
          }

          postActions.add(OFMutePostTile(
            post: post,
            onMutedPost: _dismiss,
            onUnmutedPost: _dismiss,
          ));

          if (loggedInUser.canDisableOrEnableCommentsForPost(post)) {
            postActions.add(OFDisableCommentsPostTile(
              post: post,
              onDisableComments: _dismiss,
              onEnableComments: _dismiss,
            ));
          }

          if (loggedInUser.canCloseOrOpenPost(post)) {
            postActions.add(OFClosePostTile(
              post: post,
              onClosePost: _dismiss,
              onOpenPost: _dismiss,
            ));
          }

          if (loggedInUser.canEditPost(post)) {
            postActions.add(ListTile(
              leading: const OFIcon(OFIcons.editPost),
              title: OFText(
                _localizationService.post__edit_title,
              ),
              onTap: _onWantsToEditPost,
            ));
          }

          if (loggedInUser.canDeletePost(post)) {
            postActions.add(ListTile(
              leading: const OFIcon(OFIcons.deletePost),
              title: OFText(
                _localizationService.post__actions_delete,
              ),
              onTap: _onWantsToDeletePost,
            ));
          } else {
            postActions.add(OFReportPostTile(
              post: widget.post,
              onWantsToReportPost: _dismiss,
              onPostReported: widget.onPostReported,
            ));
          }

          return OFRoundedBottomSheet(
            child: Column(
              children: postActions,
              mainAxisSize: MainAxisSize.min,
            ),
          );
        });
  }

  Future _onWantsToDeletePost() async {
    _bottomSheetService.showConfirmAction(
        context: context,
        subtitle: _localizationService.post__actions_delete_description,
        actionCompleter: (BuildContext context) async {
          await _userService.deletePost(widget.post);
          _toastService.success(
              message: _localizationService.post__actions_deleted,
              context: context);
          widget.onPostDeleted(widget.post);
        });
  }

  Future _onWantsToEditPost() async {
    try {
      await _modalService.openEditPost(context: context, post: widget.post);
      _dismiss();
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _dismiss() {
    _bottomSheetService.dismissActiveBottomSheet(context: context);
  }
}

