import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/avatars/hashtag_avatar.dart';
import 'package:onef/widgets/hashtag.dart';

class OFHashtagTile extends StatelessWidget {
  final Hashtag hashtag;
  final ValueChanged<Hashtag> onHashtagTilePressed;
  final ValueChanged<Hashtag> onHashtagTileDeleted;

  const OFHashtagTile(this.hashtag,
      {Key key, this.onHashtagTilePressed, this.onHashtagTileDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile = ListTile(
        onTap: () {
          if (onHashtagTilePressed != null) onHashtagTilePressed(hashtag);
        },
        leading: OFHashtagAvatar(
          key: Key('Avatar-${hashtag.name}'),
          hashtag: hashtag,
          size: OFAvatarSize.medium,
        ),
        title: Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: OFHashtag(
              hashtag: hashtag,
            ),
          )
        ]));
    return tile;
  }
}
