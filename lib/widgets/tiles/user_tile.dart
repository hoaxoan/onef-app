import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFUserTile extends StatelessWidget {
  final User user;
  final OnUserTilePressed onUserTilePressed;
  final OnUserTileDeleted onUserTileDeleted;
  final bool showFollowing;
  final Widget trailing;

  const OFUserTile(this.user,
      {Key key,
      this.onUserTilePressed,
      this.onUserTileDeleted,
      this.showFollowing = false,
      this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var _localizationService = provider.localizationService;
    Widget tile = ListTile(
      onTap: () {
        if (onUserTilePressed != null) onUserTilePressed(user);
      },
      leading: OFAvatar(
        size: OFAvatarSize.medium,
        avatarUrl: user.getProfileAvatar(),
      ),
      trailing: trailing,
      title: Row(children: <Widget>[
        OFText(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _getUserBadge(user)
      ]),
      subtitle: Row(
        children: [
          OFSecondaryText(user.getProfileName()),
          showFollowing && user.isFollowing != null && user.isFollowing
              ? OFSecondaryText(
                  _localizationService.trans('user__tile_following'))
              : const SizedBox()
        ],
      ),
    );

    if (onUserTileDeleted != null) {
      tile = Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: tile,
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: _localizationService.trans('user__tile_delete'),
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              onUserTileDeleted(user);
            },
          ),
        ],
      );
    }
    return tile;
  }

  Widget _getUserBadge(User creator) {
    return const SizedBox();
  }
}

typedef void OnUserTilePressed(User user);
typedef void OnUserTileDeleted(User user);
