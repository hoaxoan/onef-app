import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/avatars/avatar.dart';

class OFLoggedInUserAvatar extends StatefulWidget {
  final OFAvatarSize size;
  final VoidCallback onPressed;

  const OFLoggedInUserAvatar({this.size, this.onPressed});

  @override
  OFLoggedInUserAvatarState createState() {
    return OFLoggedInUserAvatarState();
  }
}

/// Like the UserAvatar widget but displays the avatar of
/// the logged in user.
class OFLoggedInUserAvatarState extends State<OFLoggedInUserAvatar> {
  bool _needsBootstrap;
  UserService _userService;
  StreamSubscription _onLoggedInUserChangeSubscription;
  StreamSubscription _onUserUpdateSubscription;
  String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_onLoggedInUserChangeSubscription != null)
      _onLoggedInUserChangeSubscription.cancel();
    if (_onUserUpdateSubscription != null) _onUserUpdateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return OFAvatar(
      avatarUrl: _avatarUrl,
      size: widget.size,
      onPressed: widget.onPressed,
    );
  }

  void _bootstrap() {
    _onLoggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  void _onLoggedInUserChange(User user) {
    if (user == null) return;
    if (_onUserUpdateSubscription != null) _onUserUpdateSubscription.cancel();
    _onUserUpdateSubscription =
        user.updateSubject.listen(_onLoggedInUserUpdate);
  }

  void _onLoggedInUserUpdate(User user) {
    _setAvatarUrl(user.getProfileAvatar());
  }

  void _setAvatarUrl(String avatarUrl) {
    setState(() {
      _avatarUrl = avatarUrl;
    });
  }
}
