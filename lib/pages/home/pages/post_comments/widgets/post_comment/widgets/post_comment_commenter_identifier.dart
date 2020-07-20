import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/user_badge.dart';

class OFPostCommentCommenterIdentifier extends StatelessWidget {
  final PostComment postComment;
  final Post post;
  final VoidCallback onUsernamePressed;

  static int postCommentMaxVisibleLength = 500;

  OFPostCommentCommenterIdentifier({
    Key key,
    @required this.onUsernamePressed,
    @required this.postComment,
    @required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParserService = provider.themeValueParserService;
    var utilsService = provider.utilsService;
    var localizationService = provider.localizationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          OFTheme theme = snapshot.data;

          Color secondaryTextColor =
              themeValueParserService.parseColor(theme.secondaryTextColor);

          String commenterUsername = postComment.commenter.username;
          String commenterName = postComment.commenter.getProfileName();
          String created = utilsService.timeAgo(postComment.created, localizationService);

          return Opacity(
            opacity: 0.8,
            child: GestureDetector(
              onTap: onUsernamePressed,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          style: TextStyle(
                              color: secondaryTextColor, fontSize: 14),
                          children: [
                            TextSpan(
                                text: '$commenterName',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: ' @$commenterUsername',
                                style: TextStyle(fontSize: 12)),
                          ]),
                    ),
                  ),
                  _buildBadge(),
                  OFSecondaryText(
                    ' · $created',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildBadge() {
    User postCommenter = postComment.commenter;

    List<Widget> badges = [];

    if (postCommenter.hasProfileBadges()) badges.add(_buildProfileBadge());

    if (post.hasCommunity()) {
      Community postCommunity = post.community;

      bool isCommunityAdministrator =
          postCommenter.isAdministratorOfCommunity(postCommunity);

      if (isCommunityAdministrator) {
        badges.add(_buildCommunityAdministratorBadge());
      }

      bool isCommunityModerator =
          postCommenter.isModeratorOfCommunity(postCommunity);

      if (isCommunityModerator) {
        badges.add(_buildCommunityModeratorBadge());
      }
    }

    return badges.isNotEmpty ? Row(children: badges,) : const SizedBox();
  }

  Widget _buildCommunityAdministratorBadge() {
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: OFIcon(
        OFIcons.communityAdministrators,
        size: OFIconSize.small,
        themeColor: OFIconThemeColor.primaryAccent,
      ),
    );
  }

  Widget _buildCommunityModeratorBadge() {
    return const Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: OFIcon(
          OFIcons.communityModerators,
          size: OFIconSize.small,
          themeColor: OFIconThemeColor.primaryAccent,
        ));
  }

  Widget _buildProfileBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: OFUserBadge(
          badge: postComment.commenter.getDisplayedProfileBadge(),
          size: OFUserBadgeSize.small),
    );
  }
}
