import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

import '../loading_tile.dart';

class OFClosePostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onClosePost;
  final VoidCallback onOpenPost;

  const OFClosePostTile({
    Key key,
    @required this.post,
    this.onClosePost,
    this.onOpenPost,
  }) : super(key: key);

  @override
  OFClosePostTileState createState() {
    return OFClosePostTileState();
  }
}

class OFClosePostTileState extends State<OFClosePostTile> {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;
    _localizationService = provider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool isPostClosed = post.isClosed;

        return OFLoadingTile(
          isLoading: _requestInProgress,
          leading: OFIcon(isPostClosed ? OFIcons.openPost : OFIcons.closePost),
          title: OFText(isPostClosed
              ? _localizationService.post__open_post
              : _localizationService.post__close_post),
          onTap: isPostClosed ? _openPost : _closePost,
        );
      },
    );
  }

  void _openPost() async {
    _setRequestInProgress(true);
    try {
      await _userService.openPost(widget.post);
      if (widget.onClosePost != null) widget.onClosePost();
      _toastService.success(message: _localizationService.post__post_opened, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _closePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.closePost(widget.post);
      if (widget.onOpenPost != null) widget.onOpenPost();
      _toastService.success(message: _localizationService.post__post_closed, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
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
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
