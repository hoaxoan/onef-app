import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFUserPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post> onPostReported;
  final OFPostDisplayContext displayContext;
  final bool hasActions;

  const OFUserPostHeader(this._post,
      {Key key,
      @required this.onPostDeleted,
      this.onPostReported,
      this.hasActions = true,
      this.displayContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var navigationService = provider.navigationService;
    var bottomSheetService = provider.bottomSheetService;
    var utilsService = provider.utilsService;
    var localizationService = provider.localizationService;

    if (_post.creator == null) return const SizedBox();

    String subtitle = '@${_post.creator.username}';

    if (_post.created != null)
      subtitle =
          '$subtitle · ${utilsService.timeAgo(_post.created, localizationService)}';

    Function navigateToUserProfile = () {
      navigationService.navigateToUserProfile(
          user: _post.creator, context: context);
    };

    return ListTile(
        onTap: navigateToUserProfile,
        leading: StreamBuilder(
            stream: _post.creator.updateSubject,
            initialData: _post.creator,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              User postCreator = snapshot.data;

              if (!postCreator.hasProfileAvatar()) return const SizedBox();

              return OFAvatar(
                size: OFAvatarSize.medium,
                avatarUrl: postCreator.getProfileAvatar(),
              );
            }),
        trailing: hasActions
            ? IconButton(
                icon: const OFIcon(OFIcons.moreVertical),
                onPressed: () {
                  bottomSheetService.showPostActions(
                      context: context,
                      post: _post,
                      onPostDeleted: onPostDeleted,
                      displayContext: displayContext,
                      onPostReported: onPostReported);
                })
            : null,
        title: Row(
          children: <Widget>[
            Flexible(
              child: OFText(
                _post.creator != null ? _post.creator.getProfileName() : "",
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            _buildBadge()
          ],
        ),
        subtitle: OFSecondaryText(
          subtitle,
          style: TextStyle(fontSize: 12.0),
        ));
  }

  Widget _buildBadge() {
    /*User postCommenter = _post.creator;

    if (postCommenter.hasProfileBadges())
      return OFUserBadge(
          badge: _post.creator.getDisplayedProfileBadge(),
          size: OFUserBadgeSize.small);*/

    return const SizedBox();
  }
}
