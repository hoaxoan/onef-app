import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/emoji.dart';
import 'package:onef/models/emoji_group.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_reaction.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/emoji_picker/emoji_picker.dart';

class OFReactToPostBottomSheet extends StatefulWidget {
  final Post post;

  const OFReactToPostBottomSheet(this.post);

  @override
  State<StatefulWidget> createState() {
    return OFReactToPostBottomSheetState();
  }
}

class OFReactToPostBottomSheetState extends State<OFReactToPostBottomSheet> {
  UserService _userService;
  ToastService _toastService;

  bool _isReactToPostInProgress;
  CancelableOperation _reactOperation;

  @override
  void initState() {
    super.initState();
    _isReactToPostInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (_reactOperation != null) _reactOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;

    double screenHeight = MediaQuery.of(context).size.height;

    return OFRoundedBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: screenHeight / 3,
            child: IgnorePointer(
              ignoring: _isReactToPostInProgress,
              child: Opacity(
                opacity: _isReactToPostInProgress ? 0.5 : 1,
                child: OFEmojiPicker(
                  hasSearch: false,
                  isReactionsPicker: true,
                  onEmojiPicked: _reactToPost,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _reactToPost(Emoji emoji, EmojiGroup emojiGroup) async {
    if (_isReactToPostInProgress) return null;
    _setReactToPostInProgress(true);

    try {
      _reactOperation = CancelableOperation.fromFuture(_userService.reactToPost(
          post: widget.post, emoji: emoji));

      PostReaction postReaction = await _reactOperation.value;
      widget.post.setReaction(postReaction);
      // Remove modal
      Navigator.pop(context);
      _setReactToPostInProgress(false);
    } catch (error) {
      _onError(error);
      _setReactToPostInProgress(false);
    } finally {
      _reactOperation = null;
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

  void _setReactToPostInProgress(bool reactToPostInProgress) {
    setState(() {
      _isReactToPostInProgress = reactToPostInProgress;
    });
  }
}

typedef void OnPostCreatedCallback(PostReaction reaction);
