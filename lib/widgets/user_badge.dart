import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/badge.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/icon.dart';
import 'package:shimmer/shimmer.dart';

class OFUserBadge extends StatelessWidget {
  final Badge badge;
  final OFUserBadgeSize size;
  static double badgeSizeLarge = 45;
  static double badgeSizeMedium = 25;
  static double badgeSizeSmall = 15;
  static double badgeSizeExtraSmall = 10;

  static double iconSizeLarge = 28;
  static double iconSizeMedium = 18;
  static double iconSizeSmall = 12;
  static double iconSizeExtraSmall = 8;


  const OFUserBadge({Key key, this.badge, this.size = OFUserBadgeSize.medium}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;

    if (badge == null) return const SizedBox();

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {

          switch(badge.getKeyword()) {
            case BadgeKeyword.verified:
              return _getVerifiedBadge(badge); break;
            case BadgeKeyword.founder:
              return _getFounderBadge(badge); break;
            case BadgeKeyword.golden_founder:
              return _getGoldenFounderBadge(badge); break;
            case BadgeKeyword.diamond_founder:
              return _getDiamondFounderBadge(badge); break;
            case BadgeKeyword.super_founder:
              return _getSuperFounderBadge(badge); break;
            case BadgeKeyword.angel:
              return _getAngelBadge(badge); break;
            default:
              return const SizedBox(); break;
          }
        });
  }

  Widget _getVerifiedBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);

    return Container(
      margin: EdgeInsets.only(left: 4.0, right: 4.0),
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 0.6, 0.8],
            colors: [
              Colors.blue[300],
              Colors.blueAccent[200],
              Colors.blue[800],
            ],
          ),
          borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: OFIcon(OFIcons.check, customSize: _getUserBadgeIconSize(size), color: Colors.white),
      ),
    );
  }

  Widget _getAngelBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);
    double iconSize = _getUserBadgeIconSize(size);

    return Stack(
          children: <Widget>[
            Shimmer.fromColors(
              baseColor: Colors.pink,
              highlightColor: Colors.pinkAccent[100],
              child: Container(
                margin: EdgeInsets.only(left: 4.0, right: 4.0),
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                    color: Colors.pink[200],
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(50)
                ),
                child: SizedBox(),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              child: OFIcon(OFIcons.check, customSize: iconSize, color: Colors.white),
            ),
          ],
        );
  }

  Widget _getFounderBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);

    return Container(
      margin: EdgeInsets.only(left: 4.0, right: 4.0),
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.2, 0.5, 0.8, 0.9],
            colors: [
              Colors.green[300],
              Colors.lightGreenAccent[700],
              Colors.yellow[400],
              Colors.yellow[700],
              Colors.orange[400],
            ]
          ),
          borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: OFIcon(OFIcons.check, customSize: _getUserBadgeIconSize(size), color: Colors.white),
      ),
    );
  }

  Widget _getGoldenFounderBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);

    return Container(
      margin: EdgeInsets.only(left: 4.0, right: 4.0),
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.3, 0.8],
            colors: [
              Colors.yellowAccent[400],
              Colors.yellow[700],
              Colors.yellow[800],
            ],
          ),
          borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: OFIcon(OFIcons.check, customSize: _getUserBadgeIconSize(size), color: Colors.white),
      ),
    );
  }

  Widget _getDiamondFounderBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);

    return Container(
      margin: EdgeInsets.only(left: 4.0, right: 4.0),
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 0.6, 0.8],
            colors: [
              Colors.red[100],
              Colors.redAccent[100],
              Colors.red[300],
            ],
          ),
          borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: OFIcon(OFIcons.check, customSize: _getUserBadgeIconSize(size), color: Colors.white),
      ),
    );
  }

  Widget _getSuperFounderBadge(Badge badge) {
    double badgeSize = _getUserBadgeSize(size);

    return Container(
      margin: EdgeInsets.only(left: 4.0, right: 4.0),
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.5, 0.8],
            colors: [
              Colors.deepPurple[200],
              Colors.deepPurple[100],
              Colors.blue[200],
            ],
          ),
          borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: OFIcon(OFIcons.check, customSize: _getUserBadgeIconSize(size), color: Colors.white),
      ),
    );
  }

  double _getUserBadgeIconSize(OFUserBadgeSize size) {
    double iconSize;

    switch (size) {
      case OFUserBadgeSize.large:
        iconSize = iconSizeLarge;
        break;
      case OFUserBadgeSize.medium:
        iconSize = iconSizeMedium;
        break;
      case OFUserBadgeSize.small:
        iconSize = iconSizeSmall;
        break;
      case OFUserBadgeSize.extraSmall:
        iconSize = iconSizeExtraSmall;
        break;
    }

    return iconSize;
  }

  double _getUserBadgeSize(OFUserBadgeSize size) {
    double badgeSize;

    switch (size) {
      case OFUserBadgeSize.large:
        badgeSize = badgeSizeLarge;
        break;
      case OFUserBadgeSize.medium:
        badgeSize = badgeSizeMedium;
        break;
      case OFUserBadgeSize.small:
        badgeSize = badgeSizeSmall;
        break;
      case OFUserBadgeSize.extraSmall:
        badgeSize = badgeSizeExtraSmall;
        break;
    }

    return badgeSize;
  }
}

enum OFUserBadgeSize { small, medium, large, extraSmall }
