import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/communities_list.dart';
import 'package:onef/models/community.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/http_list.dart';
import 'package:onef/widgets/nav_bars/themed_nav_bar.dart';
import 'package:onef/widgets/new_post_data_uploader.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';
import 'package:onef/widgets/tiles/community_selectable_tile.dart';

class OFSharePostWithCommunityPage extends StatefulWidget {
  final OFNewPostData createPostData;

  const OFSharePostWithCommunityPage({Key key, @required this.createPostData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFSharePostWithCommunityPageState();
  }
}

class OFSharePostWithCommunityPageState extends State<OFSharePostWithCommunityPage> {
  UserService _userService;
  LocalizationService _localizationService;

  Community _chosenCommunity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _localizationService = provider.localizationService;

    return OFCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OFPrimaryColorContainer(
          child: _buildAvailableAudience(),
        ));
  }

  Widget _buildAvailableAudience() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: OFHttpList<Community>(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          separatorBuilder: _buildCommunitySeparator,
          listItemBuilder: _buildCommunityItem,
          searchResultListItemBuilder: _buildCommunityItem,
          listRefresher: _refreshCommunities,
          listOnScrollLoader: _loadMoreCommunities,
          listSearcher: _searchCommunities,
          resourceSingularName: _localizationService.trans('community__community'),
          resourcePluralName: _localizationService.trans('community__communities'),
        ))
      ],
    );
  }

  Widget _buildNavigationBar() {
    return OFThemedNavigationBar(
      title: _localizationService.trans('post__share_to_community'),
      trailing: OFButton(
        size: OFButtonSize.small,
        type: OFButtonType.primary,
        isDisabled: _chosenCommunity == null,
        onPressed: createPost,
        child: Text(_localizationService.trans('post__share_community')),
      ),
    );
  }

  Widget _buildCommunityItem(BuildContext context, Community community) {
    return OFCommunitySelectableTile(
      community: community,
      onCommunityPressed: _onCommunityPressed,
      isSelected: community == _chosenCommunity,
    );
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  Future<void> createPost() async {
    widget.createPostData.setCommunity(_chosenCommunity);

    Navigator.pop(context, widget.createPostData);
  }

  Future<List<Community>> _refreshCommunities() async {
   /* CommunitiesList communities = await _userService.getJoinedCommunities();
    return communities.communities;*/
  }

  Future<List<Community>> _loadMoreCommunities(
      List<Community> communitiesList) async {
    int offset = communitiesList.length;

   /* List<Community> moreCommunities = (await _userService.getJoinedCommunities(
      offset: offset,
    ))
        .communities;
    return moreCommunities;*/
  }

  Future<List<Community>> _searchCommunities(String query) async {
   /* CommunitiesList results =
        await _userService.searchJoinedCommunities(query: query);

    return results.communities;*/
  }

  void _onCommunityPressed(Community pressedCommunity) {
    if (pressedCommunity == _chosenCommunity) {
      _clearChosenCommunity();
    } else {
      _setChosenCommunity(pressedCommunity);
    }
  }

  void _clearChosenCommunity() {
    _setChosenCommunity(null);
  }

  void _setChosenCommunity(Community chosenCommunity) {
    setState(() {
      _chosenCommunity = chosenCommunity;
    });
  }
}
