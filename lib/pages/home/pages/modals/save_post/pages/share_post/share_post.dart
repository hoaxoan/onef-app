import 'package:flutter/material.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/nav_bars/themed_nav_bar.dart';
import 'package:onef/widgets/new_post_data_uploader.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/progress_indicator.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';
import 'package:onef/widgets/theming/text.dart';

class OFSharePostPage extends StatefulWidget {
  final OFNewPostData createPostData;

  const OFSharePostPage({Key key, @required this.createPostData})
      : super(key: key);

  @override
  OFSharePostPageState createState() {
    return OFSharePostPageState();
  }
}

class OFSharePostPageState extends State<OFSharePostPage> {
  bool _loggedInUserRefreshInProgress;
  bool _needsBootstrap;
  UserService _userService;
  NavigationService _navigationService;
  LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _loggedInUserRefreshInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _localizationService = provider.localizationService;
      _navigationService = provider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    User loggedInUser = _userService.getLoggedInUser();

    return OFCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OFPrimaryColorContainer(
          child: StreamBuilder(
            initialData: loggedInUser,
            stream: loggedInUser.updateSubject,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              User latestUser = snapshot.data;

              if (_loggedInUserRefreshInProgress)
                return const Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: const OFProgressIndicator(),
                  ),
                );

              const TextStyle shareToTilesSubtitleStyle =
                  TextStyle(fontSize: 14);

              List<Widget> shareToTiles = [
                ListTile(
                  leading: const OFIcon(OFIcons.circles),
                  title: OFText(_localizationService.trans('post__my_circles')),
                  subtitle: OFText(
                    _localizationService.trans('post__my_circles_desc'),
                    style: shareToTilesSubtitleStyle,
                  ),
                  onTap: _onWantsToSharePostToCircles,
                )
              ];

              if (latestUser.isMemberOfCommunities != null && latestUser.isMemberOfCommunities) {
                shareToTiles.add(ListTile(
                  leading: const OFIcon(OFIcons.communities),
                  title: OFText(_localizationService
                      .trans('post__share_community_title')),
                  subtitle: OFText(
                    _localizationService.trans('post__share_community_desc'),
                    style: shareToTilesSubtitleStyle,
                  ),
                  onTap: _onWantsToSharePostToCommunity,
                ));
              }

              return Column(
                children: <Widget>[
                  Expanded(
                      child: ListView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: shareToTiles)),
                ],
              );
            },
          ),
        ));
  }

  Widget _buildNavigationBar() {
    return OFThemedNavigationBar(
      title: _localizationService.trans('post__share_to'),
    );
  }

  void _bootstrap() {
    _refreshLoggedInUser();
  }

  Future<void> _refreshLoggedInUser() async {
    User refreshedUser = await _userService.refreshUser();
    if (!refreshedUser.isMemberOfCommunities) {
      // Only possibility
      _onWantsToSharePostToCircles();
    }
  }

  void _onWantsToSharePostToCircles() async {
    OFNewPostData createPostData =
        await _navigationService.navigateToSharePostWithCircles(
            context: context, createPostData: widget.createPostData);
    if (createPostData != null) Navigator.pop(context, createPostData);
  }

  void _onWantsToSharePostToCommunity() async {
    OFNewPostData createPostData =
        await _navigationService.navigateToSharePostWithCommunity(
            context: context, createPostData: widget.createPostData);
    if (createPostData != null) Navigator.pop(context, createPostData);
  }
}
