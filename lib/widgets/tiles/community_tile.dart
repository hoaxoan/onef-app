import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onef/libs/util/pretty_count.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/avatars/letter_avatar.dart';
import 'package:tinycolor/tinycolor.dart';

class OFCommunityTile extends StatelessWidget {
  static const COVER_PLACEHOLDER = 'assets/images/fallbacks/cover-fallback.jpg';

  static const double smallSizeHeight = 60;
  static const double normalSizeHeight = 80;

  final Community community;
  final ValueChanged<Community> onCommunityTilePressed;
  final ValueChanged<Community> onCommunityTileDeleted;
  final OFCommunityTileSize size;
  final Widget trailing;

  const OFCommunityTile(this.community,
      {this.onCommunityTilePressed,
      this.onCommunityTileDeleted,
      Key key,
      this.size = OFCommunityTileSize.normal, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String communityHexColor = community.color;
    var provider = OneFProvider.of(context);
    LocalizationService localizationService = provider.localizationService;
    ThemeService themeService = provider.themeService;
    ThemeValueParserService themeValueParserService = provider.themeValueParserService;
    Color communityColor =
        themeValueParserService.parseColor(communityHexColor);
    OFTheme theme = themeService.getActiveTheme();
    Color textColor;

    BoxDecoration containerDecoration;
    BorderRadius containerBorderRadius = BorderRadius.circular(10);
    bool isCommunityColorDark =
        themeValueParserService.isDarkColor(communityColor);
    bool communityHasCover = community.hasCover();

    if (communityHasCover) {
      textColor = Colors.white;
      containerDecoration = BoxDecoration(
          borderRadius: containerBorderRadius,
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.60), BlendMode.darken),
              image: AdvancedNetworkImage(community.cover,
                  useDiskCache: true,
                  fallbackAssetImage: COVER_PLACEHOLDER,
                  retryLimit: 0)));
    } else {
      textColor = isCommunityColorDark ? Colors.white : Colors.black;
      bool communityColorIsNearWhite = communityColor.computeLuminance() > 0.9;

      containerDecoration = BoxDecoration(
        color: communityColorIsNearWhite
            ? TinyColor(communityColor).darken(5).color
            : TinyColor(communityColor).lighten(10).color,
        borderRadius: containerBorderRadius,
      );
    }

    bool isNormalSize = size == OFCommunityTileSize.normal;

    Widget communityAvatar;
    if (community.hasAvatar()) {
      communityAvatar = OFAvatar(
        avatarUrl: community.avatar,
        size: isNormalSize ? OFAvatarSize.medium : OFAvatarSize.small,
      );
    } else {
      Color avatarColor = communityHasCover
          ? communityColor
          : (isCommunityColorDark
              ? TinyColor(communityColor).lighten(5).color
              : communityColor);
      communityAvatar = OFLetterAvatar(
        letter: community.name[0],
        color: avatarColor,
        labelColor: textColor,
        size: isNormalSize ? OFAvatarSize.medium : OFAvatarSize.small,
      );
    }

    String userAdjective = community.userAdjective ?? localizationService.community__member_capitalized;
    String usersAdjective = community.usersAdjective ?? localizationService.community__members_capitalized;
    String membersPrettyCount = community.membersCount != null
        ? getPrettyCount(community.membersCount, localizationService)
        : null;
    String finalAdjective =
        community.membersCount == 1 ? userAdjective : usersAdjective;

    Widget communityTile = Container(
      height: isNormalSize ? normalSizeHeight : smallSizeHeight,
      decoration: containerDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: communityAvatar,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('c/' + community.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis),
                Text(
                  community.title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                isNormalSize && membersPrettyCount != null
                    ? Text(
                        '$membersPrettyCount $finalAdjective',
                        style: TextStyle(color: textColor, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox()
              ],
            ),
          ),
          trailing == null ? SizedBox(
            width: 20,
          ) : Padding(
            child: trailing,
            padding: const EdgeInsets.all(20),
          )
        ],
      ),
    );

    if (onCommunityTileDeleted != null && onCommunityTilePressed != null) {
      communityTile = Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: GestureDetector(
          onTap: () {
            onCommunityTilePressed(community);
          },
          child: communityTile,
        ),
        secondaryActions: <Widget>[
          new IconSlideAction(
              caption: localizationService.community__tile_delete,
              foregroundColor: themeValueParserService.parseColor(theme.primaryTextColor),
              color: Colors.transparent,
              icon: Icons.delete,
              onTap: () {
                onCommunityTileDeleted(community);
              }),
        ],
      );
    } else if (onCommunityTilePressed != null) {
      communityTile = GestureDetector(
        onTap: () {
          onCommunityTilePressed(community);
        },
        child: communityTile,
      );
    }

    return communityTile;
  }
}

enum OFCommunityTileSize { normal, small }
