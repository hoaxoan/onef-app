import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/post_comment_reaction.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostCommentActions extends StatefulWidget {
  final ValueChanged<PostComment> onReplyDeleted;
  final ValueChanged<PostComment> onReplyAdded;
  final ValueChanged<PostComment> onPostCommentDeleted;
  final ValueChanged<PostComment> onPostCommentReported;
  final Post post;
  final PostComment postComment;
  final bool showReplyAction;

  const OFPostCommentActions(
      {Key key,
      @required this.post,
      @required this.postComment,
      this.onReplyDeleted,
      this.onReplyAdded,
      this.onPostCommentDeleted,
      this.onPostCommentReported,
      this.showReplyAction = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFPostCommentActionsState();
  }
}

class OFPostCommentActionsState extends State<OFPostCommentActions> {
  ModalService _modalService;
  NavigationService _navigationService;
  BottomSheetService _bottomSheetService;
  UserService _userService;
  ToastService _toastService;
  ThemeService _themeService;
  LocalizationService _localizationService;
  ThemeValueParserService _themeValueParserService;

  bool _requestInProgress;
  CancelableOperation _requestOperation;

  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _bottomSheetService = provider.bottomSheetService;
      _navigationService = provider.navigationService;
      _modalService = provider.modalService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    List<Widget> actionItems = [
      _buildReactButton(),
    ];

    if (widget.showReplyAction &&
        _userService
            .getLoggedInUser()
            .canReplyPostComment(widget.postComment)) {
      actionItems.add(_buildReplyButton());
    }

    actionItems.addAll([
      _buildMoreButton(),
    ]);

    return Opacity(
      opacity: 0.8,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actionItems),
    );
  }

  Widget _buildMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
      child: GestureDetector(
          onTap: _onWantsToOpenMoreActions,
          child: SizedBox(
              child: OFIcon(
            OFIcons.moreHorizontal,
            themeColor: OFIconThemeColor.secondaryText,
          ))),
    );
  }

  Widget _buildReactButton() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
        child: GestureDetector(
          onTap: _reactToPostComment,
          child: SizedBox(
              child: StreamBuilder(
                  initialData: widget.postComment,
                  builder: (BuildContext context,
                      AsyncSnapshot<PostComment> snapshot) {
                    PostComment postComment = snapshot.data;

                    PostCommentReaction reaction = postComment.reaction;
                    bool hasReaction = reaction != null;

                    OFTheme activeTheme = _themeService.getActiveTheme();

                    return hasReaction
                        ? OFText(
                            reaction.getEmojiKeyword(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _themeValueParserService
                                    .parseGradient(
                                        activeTheme.primaryAccentColor)
                                    .colors[1]),
                          )
                        : OFSecondaryText(
                            _localizationService.post__action_react,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                  })),
        ));
  }

  Widget _buildReplyButton() {

    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
        child: GestureDetector(
          onTap: _replyToPostComment,
          child: SizedBox(
              child: OFSecondaryText(
            _localizationService.post__action_reply,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_requestOperation != null) _requestOperation.cancel();
  }

  void _replyToPostComment() async {
    PostComment comment = await _modalService.openExpandedReplyCommenter(
        context: context,
        post: widget.post,
        postComment: widget.postComment,
        onReplyDeleted: widget.onReplyDeleted,
        onReplyAdded: widget.onReplyAdded);
    if (comment != null) {
      await _navigationService.navigateToPostCommentReplies(
          post: widget.post,
          postComment: widget.postComment,
          onReplyAdded: widget.onReplyAdded,
          onReplyDeleted: widget.onReplyDeleted,
          context: context);
    }
  }

  void _reactToPostComment() {
    if (widget.postComment.hasReaction()) {
      _clearPostCommentReaction();
    } else {
      _bottomSheetService.showReactToPostComment(
          post: widget.post, postComment: widget.postComment, context: context);
    }
  }

  Future _clearPostCommentReaction() async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);

    try {
      _requestOperation = CancelableOperation.fromFuture(
          _userService.deletePostCommentReaction(
              postComment: widget.postComment,
              postCommentReaction: widget.postComment.reaction,
              post: widget.post));

      await _requestOperation.value;
      widget.postComment.clearReaction();
    } catch (error) {
      _onError(error);
    } finally {
      _requestOperation = null;
      _setRequestInProgress(false);
    }
  }

  void _onWantsToOpenMoreActions() {
    _bottomSheetService.showMoreCommentActions(
        context: context,
        post: widget.post,
        postComment: widget.postComment,
        onPostCommentDeleted: widget.onPostCommentDeleted,
        onPostCommentReported: widget.onPostCommentReported);
  }

  void _setRequestInProgress(bool clearPostReactionInProgress) {
    setState(() {
      _requestInProgress = clearPostReactionInProgress;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }
}
