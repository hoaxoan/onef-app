import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';
import 'package:onef/widgets/tiles/loading_tile.dart';

class OFMutePostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onMutedPost;
  final VoidCallback onUnmutedPost;

  const OFMutePostTile({
    Key key,
    @required this.post,
    this.onMutedPost,
    this.onUnmutedPost,
  }) : super(key: key);

  @override
  OFMutePostTileState createState() {
    return OFMutePostTileState();
  }
}

class OFMutePostTileState extends State<OFMutePostTile> {
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

        bool isMuted = (post.isMuted != null && post.isMuted);

        return OFLoadingTile(
          isLoading: _requestInProgress,
          leading: OFIcon(isMuted ? OFIcons.unmutePost : OFIcons.mutePost),
          title: OFText(isMuted
              ? _localizationService.notifications__mute_post_turn_on_post_notifications
              : _localizationService.notifications__mute_post_turn_off_post_notifications),
          onTap: isMuted ? _unmutePost : _mutePost,
        );
      },
    );
  }

  void _mutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.mutePost(widget.post);
      if (widget.onMutedPost != null) widget.onMutedPost();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unmutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.unmutePost(widget.post);
      if (widget.onUnmutedPost != null) widget.onUnmutedPost();
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
