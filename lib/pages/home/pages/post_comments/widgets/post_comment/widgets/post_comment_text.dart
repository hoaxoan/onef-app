import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/theming/collapsible_smart_text.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/smart_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostCommentText extends StatefulWidget {
  final PostComment postComment;
  final Post post;
  final VoidCallback onUsernamePressed;
  final int postCommentMaxVisibleLength = 500;

  OFPostCommentText(this.postComment, this.post,
      {Key key, this.onUsernamePressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFPostCommentTextState();
  }
}

class OFPostCommentTextState extends State<OFPostCommentText> {
  String _translatedText;
  bool _requestInProgress;
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _toastService = provider.toastService;
    _userService = provider.userService;
    _localizationService = provider.localizationService;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.postComment.text));
                  provider.toastService.toast(
                      message: 'Text copied!',
                      context: context,
                      type: ToastType.info);
                },
                child: _getActionableSmartText(widget.postComment.isEdited),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _getPostCommentTranslateButton() {
    if (_requestInProgress) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: 10.0,
            height: 10.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ));
    }

    User loggedInUser = _userService.getLoggedInUser();
    if (loggedInUser != null &&
        loggedInUser.canTranslatePostComment(widget.postComment, widget.post)) {
      return GestureDetector(
        onTap: _toggleTranslatePostComment,
        child: _translatedText != null
            ? OFSecondaryText(
                _localizationService.user__translate_show_original,
                size: OFTextSize.large)
            : OFSecondaryText(
                _localizationService.user__translate_see_translation,
                size: OFTextSize.large),
      );
    } else {
      return SizedBox();
    }
  }

  void _toggleTranslatePostComment() async {
    try {
      if (_translatedText == null) {
        _setRequestInProgress(true);
        CancelableOperation<String> _getTranslationOperation =
            CancelableOperation.fromFuture(_userService.translatePostComment(
          postComment: widget.postComment,
          post: widget.post,
        ));

        String translatedText = await _getTranslationOperation.value;
        _setPostCommentTranslatedText(translatedText);
      } else {
        _setPostCommentTranslatedText(null);
      }
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  Widget _getActionableSmartText(bool isEdited) {
    if (isEdited) {
      return OFCollapsibleSmartText(
        size: OFTextSize.large,
        text: _translatedText ?? widget.postComment.text,
        trailingSmartTextElement: SecondaryTextElement(' (edited)'),
        maxlength: widget.postCommentMaxVisibleLength,
        getChild: _getPostCommentTranslateButton,
        hashtagsMap: widget.postComment.hashtagsMap,
      );
    } else {
      return OFCollapsibleSmartText(
        size: OFTextSize.large,
        text: _translatedText ?? widget.postComment.text,
        maxlength: widget.postCommentMaxVisibleLength,
        getChild: _getPostCommentTranslateButton,
        hashtagsMap: widget.postComment.hashtagsMap,
      );
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
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _setPostCommentTranslatedText(String newText) {
    setState(() {
      _translatedText = newText;
    });
  }
}
