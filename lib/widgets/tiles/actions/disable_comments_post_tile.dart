import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFDisableCommentsPostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onDisableComments;
  final VoidCallback onEnableComments;

  const OFDisableCommentsPostTile({
    Key key,
    @required this.post,
    this.onDisableComments,
    this.onEnableComments,
  }) : super(key: key);

  @override
  OFDisableCommentsPostTileState createState() {
    return OFDisableCommentsPostTileState();
  }
}

class OFDisableCommentsPostTileState extends State<OFDisableCommentsPostTile> {
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

        bool areCommentsEnabled = (post.areCommentsEnabled != null && post.areCommentsEnabled);

        return ListTile(
          enabled: !_requestInProgress,
          leading: OFIcon(areCommentsEnabled ? OFIcons.disableComments : OFIcons.enableComments),
          title: OFText(areCommentsEnabled
              ? _localizationService.post__disable_post_comments
              : _localizationService.post__enable_post_comments),
          onTap: areCommentsEnabled ? _disableComments : _enableComments,
        );
      },
    );
  }

  void _enableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.enableCommentsForPost(widget.post);
      if (widget.onDisableComments != null) widget.onDisableComments();
      _toastService.success(message: _localizationService.post__comments_enabled_message, context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _disableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.disableCommentsForPost(widget.post);
      if (widget.onEnableComments != null) widget.onEnableComments();
      _toastService.success(message: _localizationService.post__comments_disabled_message, context: context);
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
