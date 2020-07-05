import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

enum OFIconSize { small, medium, large, extraLarge }

class OFIcon extends StatelessWidget {
  final OFIconData iconData;
  final OFIconSize size;
  final double customSize;
  final Color color;
  final OFIconThemeColor themeColor;
  final String semanticLabel;

  static const double EXTRA_LARGE = 45.0;
  static const double LARGE_SIZE = 30.0;
  static const double MEDIUM_SIZE = 25.0;
  static const double SMALL_SIZE = 15.0;

  const OFIcon(this.iconData,
      {Key key,
      this.size,
      this.customSize,
      this.color,
      this.themeColor,
      this.semanticLabel})
      : assert(!(color != null && themeColor != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize;

    if (this.customSize != null) {
      iconSize = this.customSize;
    } else {
      var finalSize = size ?? OFIconSize.medium;
      switch (finalSize) {
        case OFIconSize.extraLarge:
          iconSize = EXTRA_LARGE;
          break;
        case OFIconSize.large:
          iconSize = LARGE_SIZE;
          break;
        case OFIconSize.medium:
          iconSize = MEDIUM_SIZE;
          break;
        case OFIconSize.small:
          iconSize = SMALL_SIZE;
          break;
        default:
          throw 'Unsupported OBIconSize';
      }
    }

    var themeService = OneFProvider.of(context).themeService;
    var themeValueParser = OneFProvider.of(context).themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;

          Widget icon;

          if (iconData.nativeIcon != null) {
            Color iconColor;
            Gradient iconGradient;

            if (color != null) {
              iconColor = color;
            } else {
              switch (themeColor) {
                case OFIconThemeColor.primary:
                  iconColor = themeValueParser.parseColor(theme.primaryColor);
                  break;
                case OFIconThemeColor.primaryText:
                  iconColor =
                      themeValueParser.parseColor(theme.primaryTextColor);
                  break;
                case OFIconThemeColor.secondaryText:
                  iconColor =
                      themeValueParser.parseColor(theme.secondaryTextColor);
                  break;
                case OFIconThemeColor.primaryAccent:
                  iconGradient =
                      themeValueParser.parseGradient(theme.primaryAccentColor);
                  break;
                case OFIconThemeColor.danger:
                  iconGradient =
                      themeValueParser.parseGradient(theme.dangerColor);
                  break;
                default:
                  iconColor =
                      themeValueParser.parseColor(theme.primaryTextColor);
              }
            }

            if (iconColor != null) {
              icon = Icon(
                iconData.nativeIcon,
                size: iconSize,
                color: iconColor,
                semanticLabel: semanticLabel,
              );
            } else {
              icon = ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) {
                  return iconGradient.createShader(bounds);
                },
                child: Icon(
                  iconData.nativeIcon,
                  color: Colors.white,
                  size: iconSize,
                ),
              );
            }
          } else {
            String iconName = iconData.filename;
            icon =
                Image.asset('assets/images/icons/$iconName', height: iconSize);
          }

          return icon;
        });
  }
}

class OFIcons {
  static const home = OFIconData(nativeIcon: Icons.home);
  static const cash_back = OFIconData(nativeIcon: Icons.monetization_on);
  static const explore = OFIconData(nativeIcon: Icons.public);
  static const trending = OFIconData(nativeIcon: Icons.whatshot);
  static const pause = OFIconData(nativeIcon: Icons.pause);
  static const play_arrow = OFIconData(nativeIcon: Icons.play_arrow);
  static const fullscreen_exit = OFIconData(nativeIcon: Icons.fullscreen_exit);
  static const fullscreen = OFIconData(nativeIcon: Icons.fullscreen);
  static const volume_up = OFIconData(nativeIcon: Icons.volume_up);
  static const volume_off = OFIconData(nativeIcon: Icons.volume_off);
  static const search = OFIconData(nativeIcon: Icons.search);
  static const okuna_age_baby = OFIconData(nativeIcon: Icons.child_care);
  static const okuna_age_smile =
      OFIconData(nativeIcon: Icons.sentiment_satisfied);
  static const notifications = OFIconData(nativeIcon: Icons.notifications);
  static const notifications_off =
      OFIconData(nativeIcon: Icons.notifications_off);
  static const language = OFIconData(nativeIcon: Icons.language);
  static const translate = OFIconData(nativeIcon: Icons.translate);
  static const menu = OFIconData(nativeIcon: Icons.menu);
  static const communities = OFIconData(nativeIcon: Icons.bubble_chart);
  static const settings = OFIconData(nativeIcon: Icons.settings);
  static const lists = OFIconData(nativeIcon: Icons.library_books);
  static const addToList = OFIconData(nativeIcon: Icons.queue);
  static const removeFromList = OFIconData(nativeIcon: Icons.delete);
  static const customize = OFIconData(nativeIcon: Icons.format_paint);
  static const logout = OFIconData(nativeIcon: Icons.exit_to_app);
  static const help = OFIconData(nativeIcon: Icons.help);
  static const refresh = OFIconData(nativeIcon: Icons.refresh);
  static const retry = OFIconData(nativeIcon: Icons.refresh);
  static const connections = OFIconData(nativeIcon: Icons.people);
  static const createPost = OFIconData(nativeIcon: Icons.add);
  static const add = OFIconData(nativeIcon: Icons.add);
  static const loadMore = OFIconData(nativeIcon: Icons.add);
  static const moreVertical = OFIconData(nativeIcon: Icons.more_vert);
  static const moreHorizontal = OFIconData(nativeIcon: Icons.more_horiz);
  static const react = OFIconData(nativeIcon: Icons.sentiment_very_satisfied);
  static const comment = OFIconData(nativeIcon: Icons.chat_bubble_outline);
  static const chat = OFIconData(nativeIcon: Icons.chat);
  static const close = OFIconData(nativeIcon: Icons.close);
  static const cancel = OFIconData(nativeIcon: Icons.close);
  static const sad = OFIconData(nativeIcon: Icons.sentiment_dissatisfied);
  static const happy = OFIconData(nativeIcon: Icons.sentiment_very_satisfied);
  static const location = OFIconData(nativeIcon: Icons.location_on);
  static const link = OFIconData(nativeIcon: Icons.link);
  static const linkOff = OFIconData(nativeIcon: Icons.link_off);
  static const email = OFIconData(nativeIcon: Icons.email);
  static const lock = OFIconData(nativeIcon: Icons.lock);
  static const bio = OFIconData(nativeIcon: Icons.bookmark);
  static const name = OFIconData(nativeIcon: Icons.person);
  static const followers = OFIconData(nativeIcon: Icons.supervisor_account);
  static const following = OFIconData(nativeIcon: Icons.person);
  static const cake = OFIconData(nativeIcon: Icons.cake);
  static const remove = OFIconData(nativeIcon: Icons.remove_circle_outline);
  static const checkCircle =
      OFIconData(nativeIcon: Icons.radio_button_unchecked);
  static const checkCircleSelected = OFIconData(nativeIcon: Icons.check_circle);
  static const check = OFIconData(nativeIcon: Icons.check);
  static const circles = OFIconData(nativeIcon: Icons.group_work);
  static const follow = OFIconData(nativeIcon: Icons.notifications);
  static const unfollow = OFIconData(nativeIcon: Icons.notifications_off);
  static const connect = OFIconData(nativeIcon: Icons.group_add);
  static const disconnect = OFIconData(nativeIcon: Icons.remove_circle_outline);
  static const deletePost = OFIconData(nativeIcon: Icons.delete);
  static const clear = OFIconData(nativeIcon: Icons.delete);
  static const report = OFIconData(nativeIcon: Icons.flag);
  static const filter = OFIconData(nativeIcon: Icons.tune);
  static const gallery = OFIconData(nativeIcon: Icons.apps);
  static const camera = OFIconData(nativeIcon: Icons.camera_alt);
  static const privateCommunity = OFIconData(nativeIcon: Icons.lock);
  static const publicCommunity = OFIconData(nativeIcon: Icons.public);
  static const communityDescription = OFIconData(nativeIcon: Icons.book);
  static const communityTitle = OFIconData(nativeIcon: Icons.public);
  static const communityName = OFIconData(nativeIcon: Icons.public);
  static const communityRules = OFIconData(nativeIcon: Icons.straighten);
  static const category = OFIconData(nativeIcon: Icons.category);
  static const communityMember = OFIconData(nativeIcon: Icons.person);
  static const communityMembers = OFIconData(nativeIcon: Icons.people);
  static const color = OFIconData(nativeIcon: Icons.format_paint);
  static const shortText = OFIconData(nativeIcon: Icons.short_text);
  static const communityAdministrators = OFIconData(nativeIcon: Icons.star);
  static const communityModerators = OFIconData(nativeIcon: Icons.gavel);
  static const communityBannedUsers = OFIconData(nativeIcon: Icons.block);
  static const deleteCommunity = OFIconData(nativeIcon: Icons.delete_forever);
  static const seeMore = OFIconData(nativeIcon: Icons.arrow_right);
  static const leaveCommunity = OFIconData(nativeIcon: Icons.exit_to_app);
  static const reportCommunity = OFIconData(nativeIcon: Icons.flag);
  static const communityInvites = OFIconData(nativeIcon: Icons.email);
  static const favoriteCommunity = OFIconData(nativeIcon: Icons.favorite);
  static const unfavoriteCommunity =
      OFIconData(nativeIcon: Icons.remove_circle);
  static const expand = OFIconData(filename: 'expand-icon.png');
  static const mutePost = OFIconData(nativeIcon: Icons.notifications_active);
  static const excludePostCommunity =
      OFIconData(nativeIcon: Icons.not_interested);
  static const undoExcludePostCommunity = OFIconData(nativeIcon: Icons.check);
  static const mutePostComment =
      OFIconData(nativeIcon: Icons.notifications_active);
  static const editPost = OFIconData(nativeIcon: Icons.edit);
  static const edit = OFIconData(nativeIcon: Icons.edit);
  static const reviewModeratedObject = OFIconData(nativeIcon: Icons.gavel);
  static const unmutePost = OFIconData(nativeIcon: Icons.notifications_off);
  static const unmutePostComment =
      OFIconData(nativeIcon: Icons.notifications_off);
  static const deleteAccount = OFIconData(nativeIcon: Icons.delete_forever);
  static const account = OFIconData(nativeIcon: Icons.account_circle);
  static const application = OFIconData(nativeIcon: Icons.phone_iphone);
  static const arrowUp = OFIconData(nativeIcon: Icons.keyboard_arrow_up);
  static const arrowUpward = OFIconData(nativeIcon: Icons.arrow_upward);
  static const bug = OFIconData(nativeIcon: Icons.bug_report);
  static const featureRequest = OFIconData(nativeIcon: Icons.new_releases);
  static const guide = OFIconData(nativeIcon: Icons.book);
  static const slackChannel = OFIconData(nativeIcon: Icons.tag_faces);
  static const dashboard = OFIconData(nativeIcon: Icons.dashboard);
  static const themes = OFIconData(nativeIcon: Icons.format_paint);
  static const invite = OFIconData(nativeIcon: Icons.card_giftcard);
  static const disableComments = OFIconData(nativeIcon: Icons.chat_bubble);
  static const enableComments =
      OFIconData(nativeIcon: Icons.chat_bubble_outline);
  static const closePost = OFIconData(nativeIcon: Icons.lock_outline);
  static const openPost = OFIconData(nativeIcon: Icons.lock_open);
  static const block = OFIconData(nativeIcon: Icons.block);
  static const chevronRight = OFIconData(nativeIcon: Icons.chevron_right);
  static const verify = OFIconData(nativeIcon: Icons.check);
  static const unverify = OFIconData(nativeIcon: Icons.close);
  static const globalModerator = OFIconData(nativeIcon: Icons.account_balance);
  static const moderationPenalties = OFIconData(nativeIcon: Icons.flag);
  static const send = OFIconData(nativeIcon: Icons.send);
  static const arrowDown = OFIconData(nativeIcon: Icons.keyboard_arrow_down);
  static const rules = OFIconData(nativeIcon: Icons.book);
  static const communityStaff = OFIconData(nativeIcon: Icons.tag_faces);
  static const reply = OFIconData(nativeIcon: Icons.reply);
  static const support = OFIconData(nativeIcon: Icons.favorite);
  static const sound = OFIconData(nativeIcon: Icons.volume_up);
  static const linkPreviews = OFIconData(nativeIcon: Icons.library_books);
  static const nativeInfo = OFIconData(nativeIcon: Icons.info);
  static const success = OFIconData(filename: 'success-icon.png');
  static const error = OFIconData(filename: 'error-icon.png');
  static const warning = OFIconData(filename: 'warning-icon.png');
  static const info = OFIconData(filename: 'info-icon.png');
  static const profile = OFIconData(filename: 'profile-icon.png');
  static const photo = OFIconData(filename: 'photo-icon.png');
  static const video = OFIconData(filename: 'video-icon.png');
  static const gif = OFIconData(filename: 'gif-icon.png');
  static const audience = OFIconData(filename: 'audience-icon.png');
  static const burner = OFIconData(filename: 'burner-icon.png');
  static const comments = OFIconData(filename: 'comments-icon.png');
  static const like = OFIconData(filename: 'like-icon.png');
  static const thinking = OFIconData(filename: 'thinking.gif');
  static const finish = OFIconData(filename: 'finish-icon.png');
  static const staff = OFIconData(filename: 'staff-icon.png');
  static const loadingMorePosts =
      OFIconData(filename: 'load-more-posts-icon.gif');
}

@immutable
class OFIconData {
  final String filename;
  final IconData nativeIcon;

  const OFIconData({
    this.nativeIcon,
    this.filename,
  });
}

enum OFIconThemeColor {
  primary,
  primaryText,
  primaryAccent,
  danger,
  success,
  secondaryText
}
