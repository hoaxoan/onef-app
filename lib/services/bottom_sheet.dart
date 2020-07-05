import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/follows_list.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/post_comment_reaction.dart';
import 'package:onef/models/post_reaction.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/bottom_sheets/confirm_action.dart';
import 'package:onef/pages/home/bottom_sheets/image_picker.dart';
import 'package:onef/pages/home/bottom_sheets/react_to_post.dart';
import 'package:onef/pages/home/bottom_sheets/video_picker.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/widgets/post/post.dart';

class BottomSheetService {
  bool hasActiveBottomSheet = false;

  Future<PostReaction> showReactToPost(
      {@required Post post, @required BuildContext context}) async {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return Material(
            child: OFReactToPostBottomSheet(post),
          );
        });
  }

  Future<PostCommentReaction> showReactToPostComment(
      {@required PostComment postComment,
        @required Post post,
        @required BuildContext context}) async {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return Material(
            child: OFReactToPostCommentBottomSheet(
                postComment: postComment, post: post),
          );*/
        });
  }

  /*void showConnectionsCirclesPicker(
      {@required BuildContext context,
        @required String title,
        @required String actionLabel,
        @required OnPickedCircles onPickedCircles,
        List<Circle> initialPickedCircles}) {
    _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFConnectionCirclesPickerBottomSheet(
            initialPickedCircles: initialPickedCircles,
            title: title,
            actionLabel: actionLabel,
            onPickedCircles: onPickedCircles,
          );
        });
  }*/

  Future<void> showCommunityTypePicker(
      {@required BuildContext context,
        ValueChanged<CommunityType> onChanged,
        CommunityType initialType}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          /*return OFCommunityTypePickerBottomSheet(
              onTypeChanged: onChanged, initialType: initialType);*/
        });
  }


  Future<void> showUserVisibilityPicker(
      {@required BuildContext context}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          //return OFUserVisibilityPickerBottomSheet();
        });
  }

  Future<void> showVideosSoundSettingPicker(
      {@required BuildContext context,
        ValueChanged<VideosSoundSetting> onChanged,
        VideosSoundSetting initialValue}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return OFVideosSoundSettingPickerBottomSheet(
              onTypeChanged: onChanged, initialValue: initialValue);*/
        });
  }

/*  Future<void> showHashtagsDisplaySettingPicker(
      {@required BuildContext context,
        ValueChanged<HashtagsDisplaySetting> onChanged,
        HashtagsDisplaySetting initialValue}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFHashtagsDisplaySettingPickerBottomSheet(
              onTypeChanged: onChanged, initialValue: initialValue);
        });
  }*/

  Future<void> showVideosAutoPlaySettingPicker(
      {@required BuildContext context,
        ValueChanged<VideosAutoPlaySetting> onChanged,
        VideosAutoPlaySetting initialValue}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return OFVideosAutoPlaySettingPickerBottomSheet(
              onTypeChanged: onChanged, initialValue: initialValue);*/
        });
  }

  Future<void> showLinkPreviewsSettingPicker(
      {@required BuildContext context,
        ValueChanged<LinkPreviewsSetting> onChanged,
        LinkPreviewsSetting initialValue}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return OFLinkPreviewsSettingPickerBottomSheet(
              onTypeChanged: onChanged, initialValue: initialValue);*/
        });
  }

  Future<List<FollowsList>> showFollowsListsPicker(
      {@required BuildContext context,
        @required String title,
        @required String actionLabel,
        List<FollowsList> initialPickedFollowsLists}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return OBFollowsListsPickerBottomSheet(
            initialPickedFollowsLists: initialPickedFollowsLists,
            title: title,
            actionLabel: actionLabel,
          );*/
        });
  }
  Future<void> showPostActions(
      {@required BuildContext context,
        @required Post post,
        @required OFPostDisplayContext displayContext,
        @required OnPostDeleted onPostDeleted,
        @required ValueChanged<Post> onPostReported,
        ValueChanged<Community> onPostCommunityExcludedFromProfilePosts,
        Function onCommunityExcluded,
        Function onUndoCommunityExcluded,
        List<FollowsList> initialPickedFollowsLists}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          /*return OFPostActionsBottomSheet(
            post: post,
            displayContext: displayContext,
            onCommunityExcluded: onCommunityExcluded,
            onUndoCommunityExcluded: onUndoCommunityExcluded,
            onPostCommunityExcludedFromProfilePosts: onPostCommunityExcludedFromProfilePosts,
            onPostDeleted: onPostDeleted,
            onPostReported: onPostReported,
          );*/
        });
  }

  Future<void> showHashtagActions(
      {@required BuildContext context,
        @required Hashtag hashtag,
        @required ValueChanged<Hashtag> onHashtagReported}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          /*return OFHashtagActionsBottomSheet(
            hashtag: hashtag,
            onHashtagReported: onHashtagReported,
          );*/
        });
  }

  Future<void> showUserActions(
      {@required BuildContext context, @required User user}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
         /* return OFUserActionsBottomSheet(
            user,
          );*/
        });
  }

 /* Future<void> showCommunityActions(
      {@required BuildContext context,
        @required Community community,
        OnCommunityReported onCommunityReported}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFCommunityActionsBottomSheet(
            community: community,
            onCommunityReported: onCommunityReported,
          );
        });
  }*/

  Future<void> showMoreCommentActions({
    @required BuildContext context,
    @required Post post,
    @required PostComment postComment,
    @required ValueChanged<PostComment> onPostCommentDeleted,
    @required ValueChanged<PostComment> onPostCommentReported,
  }) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          /*return OFPostCommentMoreActionsBottomSheet(
              onPostCommentReported: onPostCommentReported,
              onPostCommentDeleted: onPostCommentDeleted,
              post: post,
              postComment: postComment);*/
        });
  }

/*  Future<MediaFile> showCameraPicker({@required BuildContext context}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFCameraPickerBottomSheet();
        });
  }*/

  Future<File> showVideoPicker({@required BuildContext context}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFVideoPickerBottomSheet();
        });
  }

  Future<File> showImagePicker({@required BuildContext context}) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFImagePickerBottomSheet();
        });
  }

  Future<File> showConfirmAction({
    @required BuildContext context,
    String title,
    String subtitle,
    String description,
    String confirmText,
    String cancelText,
    @required ActionCompleter actionCompleter,
  }) {
    return _showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return OFConfirmActionBottomSheet(
            title: title,
            subtitle: subtitle,
            //description: description,
            confirmText: confirmText,
            cancelText: cancelText,
            actionCompleter: actionCompleter,
          );
        });
  }

  void dismissActiveBottomSheet({@required BuildContext context}) async {
    if (this.hasActiveBottomSheet) {
      Navigator.of(context, rootNavigator: true).pop();
      this.hasActiveBottomSheet = true;
    }
  }

  Future<T> _showModalBottomSheetApp<T>(
      {BuildContext context, WidgetBuilder builder}) async {
    dismissActiveBottomSheet(context: context);
    hasActiveBottomSheet = true;
    final result =
    await showModalBottomSheetApp(context: context, builder: builder);
    hasActiveBottomSheet = false;
    return result;
  }
}

//Flutter Modal Bottom Sheet
//Modified by Suvadeep Das
//Based on https://gist.github.com/andrelsmoraes/9e4af0133bff8960c1feeb0ead7fd749

const Duration _kBottomSheetDuration = const Duration(milliseconds: 200);

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.bottomInset);

  final double progress;
  final double bottomInset;

  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Mega OPENBOOK HACK!
    return new Offset(
        0.0,
        size.height -
            bottomInset +
            (bottomInset > 50 ? 50 : 0) -
            childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        bottomInset != oldDelegate.bottomInset;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({Key key, this.route}) : super(key: key);

  final _ModalBottomSheetRoute<T> route;

  @override
  _ModalBottomSheetState<T> createState() => new _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: widget.route.dismissOnTap ? () => Navigator.pop(context) : null,
        child: new AnimatedBuilder(
            animation: widget.route.animation,
            builder: (BuildContext context, Widget child) {
              double bottomInset = widget.route.resizeToAvoidBottomPadding
                  ? MediaQuery.of(context).viewInsets.bottom
                  : 0.0;
              return new ClipRect(
                  child: new CustomSingleChildLayout(
                      delegate: new _ModalBottomSheetLayout(
                          widget.route.animation.value, bottomInset),
                      child: new BottomSheet(
                          animationController:
                          widget.route._animationController,
                          onClosing: () => Navigator.pop(context),
                          builder: widget.route.builder)));
            }));
  }
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
    this.resizeToAvoidBottomPadding,
    this.dismissOnTap,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;
  final bool resizeToAvoidBottomPadding;
  final bool dismissOnTap;

  @override
  Duration get transitionDuration => _kBottomSheetDuration;

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: new _ModalBottomSheet<T>(route: this),
    );
    if (theme != null) bottomSheet = new Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

/// Shows a modal material design bottom sheet.
///
/// A modal bottom sheet is an alternative to a menu or a dialog and prevents
/// the user from interacting with the rest of the app.
///
/// A closely related widget is a persistent bottom sheet, which shows
/// information that supplements the primary content of the app without
/// preventing the use from interacting with the app. Persistent bottom sheets
/// can be created and displayed with the [showBottomSheet] function or the
/// [ScaffoldState.showBottomSheet] method.
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the bottom sheet. It is only used when the method is called. Its
/// corresponding widget can be safely removed from the tree before the bottom
/// sheet is closed.
///
/// Returns a `Future` that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal bottom sheet was closed.
///
/// See also:
///
///  * [BottomSheet], which is the widget normally returned by the function
///    passed as the `builder` argument to [showModalBottomSheet].
///  * [showBottomSheet] and [ScaffoldState.showBottomSheet], for showing
///    non-modal bottom sheets.
///  * <https://material.google.com/components/bottom-sheets.html#bottom-sheets-modal-bottom-sheets>
Future<T> showModalBottomSheetApp<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool dismissOnTap: false,
  bool resizeToAvoidBottomPadding: true,
}) {
  assert(context != null);
  assert(builder != null);
  return Navigator.of(context, rootNavigator: true)
      .push(new _ModalBottomSheetRoute<T>(
    builder: builder,
    theme: ThemeData(canvasColor: Colors.transparent),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
    dismissOnTap: dismissOnTap,
  ));
}
