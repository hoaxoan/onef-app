import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/pages/home/pages/modals/save_post/widgets/create_post_text.dart';
import 'package:onef/pages/home/pages/modals/save_post/widgets/remaining_post_characters.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/services/validation.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/avatars/logged_in_user_avatar.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/contextual_search_boxes/contextual_search_box_state.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/nav_bars/themed_nav_bar.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';

class OFPostCommenterExpandedModal extends StatefulWidget {
  final Post post;
  final PostComment postComment;

  const OFPostCommenterExpandedModal({Key key, this.post, this.postComment})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFPostCommenterExpandedModalState();
  }
}

class OFPostCommenterExpandedModalState
    extends OFContextualSearchBoxState<OFPostCommenterExpandedModal> {
  ValidationService _validationService;
  ToastService _toastService;
  UserService _userService;
  LocalizationService _localizationService;

  TextEditingController _textController;
  int _charactersCount;
  bool _isPostCommentTextAllowedLength;
  bool _isPostCommentTextOriginal;
  List<Widget> _postCommentItemsWidgets;
  String _originalText;
  bool _requestInProgress;
  bool _needsBootstrap;

  CancelableOperation _postCommentOperation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
        text: widget.postComment != null ? widget.postComment.text : '');
    _textController.addListener(_onPostCommentTextChanged);
    setAutocompleteTextController(_textController);
    _charactersCount = 0;
    _isPostCommentTextAllowedLength = false;
    _isPostCommentTextOriginal = false;
    _originalText = widget.postComment.text;
    _requestInProgress = false;
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
    _textController.removeListener(_onPostCommentTextChanged);
    if (_postCommentOperation != null) _postCommentOperation.cancel();
  }

  @override
  void bootstrap() {
    super.bootstrap();
    String hintText = widget.post.commentsCount > 0
        ? _localizationService.post__commenter_expanded_join_conversation
        : _localizationService.post__commenter_expanded_start_conversation;
    _postCommentItemsWidgets = [
      OFCreatePostText(controller: _textController, hintText: hintText)
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _validationService = provider.validationService;
      _userService = provider.userService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: _buildNavigationBar(),
        child: OFPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            _buildPostCommentEditor(),
            isAutocompleting
                ? Expanded(flex: 7, child: buildSearchBox())
                : const SizedBox()
          ],
        )));
  }

  Widget _buildNavigationBar() {
    bool isPrimaryActionButtonIsEnabled = (_isPostCommentTextAllowedLength &&
        _charactersCount > 0 &&
        !_isPostCommentTextOriginal);

    return OFThemedNavigationBar(
      leading: GestureDetector(
        child: const OFIcon(OFIcons.close),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      title: _localizationService.post__commenter_expanded_edit_comment,
      trailing:
          _buildPrimaryActionButton(isEnabled: isPrimaryActionButtonIsEnabled),
    );
  }

  Widget _buildPrimaryActionButton({bool isEnabled}) {
    return OFButton(
      isDisabled: !isEnabled,
      isLoading: _requestInProgress,
      size: OFButtonSize.small,
      onPressed: _onWantsToSaveComment,
      child: Text(_localizationService.post__commenter_expanded_save),
    );
  }

  Widget _buildPostCommentEditor() {
    return Expanded(
        flex: isAutocompleting ? 3 : 10,
        child: Padding(
          padding: EdgeInsets.only(left: 20.0, top: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  OFLoggedInUserAvatar(
                    size: OFAvatarSize.medium,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  OFRemainingPostCharacters(
                    maxCharacters: ValidationService.POST_COMMENT_MAX_LENGTH,
                    currentCharacters: _charactersCount,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 30.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _postCommentItemsWidgets)),
                ),
              )
            ],
          ),
        ));
  }

  void _onPostCommentTextChanged() {
    String text = _textController.text;
    setState(() {
      _charactersCount = text.length;
      _isPostCommentTextAllowedLength =
          _validationService.isPostCommentAllowedLength(text);
      _isPostCommentTextOriginal = _originalText == _textController.text;
    });
  }

  void _onWantsToSaveComment() async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);
    try {
      _postCommentOperation = CancelableOperation.fromFuture(
          _userService.editPostComment(
              post: widget.post,
              postComment: widget.postComment,
              text: _textController.text));

      PostComment comment = await _postCommentOperation.value;
      Navigator.pop(context, comment);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _postCommentOperation = null;
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

  void _setRequestInProgress(requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void debugLog(String log) {
    debugPrint('OBPostCommenterExpandedModal:$log');
  }
}
