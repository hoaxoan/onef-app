import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/models/user.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/progress_indicator.dart';
import 'package:onef/widgets/theming/text.dart';
import 'package:onef/widgets/tiles/hashtag_tile.dart';
import 'package:onef/widgets/tiles/user_tile.dart';

class OFSearchResults extends StatefulWidget {
  final List<User> userResults;
  final List<Hashtag> hashtagResults;
  final String searchQuery;
  final ValueChanged<User> onUserPressed;
  final ValueChanged<Hashtag> onHashtagPressed;
  final ValueChanged<OFUserSearchResultsTab> onTabSelectionChanged;
  final VoidCallback onScroll;
  final OFUserSearchResultsTab selectedTab;
  final bool userSearchInProgress;
  final bool hashtagSearchInProgress;

  const OFSearchResults(
      {Key key,
      @required this.userResults,
      this.selectedTab = OFUserSearchResultsTab.users,
      @required this.hashtagResults,
      this.userSearchInProgress = false,
      this.hashtagSearchInProgress = false,
      @required this.searchQuery,
      @required this.onUserPressed,
      @required this.onScroll,
      @required this.onHashtagPressed,
      @required this.onTabSelectionChanged})
      : super(key: key);

  @override
  OFSearchResultsState createState() {
    return OFSearchResultsState();
  }
}

class OFSearchResultsState extends State<OFSearchResults>
    with TickerProviderStateMixin {
  TabController _tabController;
  LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    switch (widget.selectedTab) {
      case OFUserSearchResultsTab.users:
        _tabController.index = 0;
        break;
        break;
      case OFUserSearchResultsTab.hashtags:
        _tabController.index = 1;
        break;
      default:
        throw 'Unhandled tab index';
    }

    _tabController.addListener(_onTabSelectionChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_onTabSelectionChanged);
  }

  @override
  void didUpdateWidget(OFSearchResults oldWidget) {
    if (oldWidget.searchQuery != widget.searchQuery) {
      this._onSearchQueryChanged(widget.searchQuery);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    ThemeService _themeService = provider.themeService;
    _localizationService = provider.localizationService;
    ThemeValueParserService _themeValueParser =
        provider.themeValueParserService;
    OFTheme theme = _themeService.getActiveTheme();

    Color tabIndicatorColor =
        _themeValueParser.parseGradient(theme.primaryAccentColor).colors[1];

    Color tabLabelColor = _themeValueParser.parseColor(theme.primaryTextColor);

    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child:
                  Tab(text: _localizationService.trans('user_search__users')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Tab(text: _localizationService.user_search__hashtags),
            )
          ],
          isScrollable: false,
          indicatorColor: tabIndicatorColor,
          labelColor: tabLabelColor,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildUserResults(), _buildHashtagResults()],
          ),
        )
      ],
    );
  }

  Widget _buildUserResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.builder(
          padding: EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.userResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.userResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.userSearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OFProgressIndicator(),
                    title: OFText(_localizationService
                        .user_search__searching_for(searchQuery)));
              } else if (widget.userResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OFIcon(OFIcons.sad),
                    title: OFText(_localizationService
                        .user_search__no_users_for(searchQuery)));
              } else {
                return SizedBox();
              }
            }

            User user = widget.userResults[index];

            return OFUserTile(
              user,
              onUserTilePressed: widget.onUserPressed,
            );
          }),
    );
  }

  Widget _buildHashtagResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.builder(
          padding: const EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.hashtagResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.hashtagResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.hashtagSearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OFProgressIndicator(),
                    title: OFText(_localizationService
                        .user_search__searching_for(searchQuery)));
              } else if (widget.hashtagResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OFIcon(OFIcons.sad),
                    title: OFText(_localizationService
                        .user_search__no_hashtags_for(searchQuery)));
              } else {
                return SizedBox();
              }
            }

            Hashtag hashtag = widget.hashtagResults[index];

            return OFHashtagTile(
              hashtag,
              key: Key(hashtag.name),
              onHashtagTilePressed: widget.onHashtagPressed,
            );
          }),
    );
  }

  void _onTabSelectionChanged() {
    OFUserSearchResultsTab newSelection =
        OFUserSearchResultsTab.values[_tabController.previousIndex];
    widget.onTabSelectionChanged(newSelection);
  }

  void _onSearchQueryChanged(String searchQuery) {
    OFUserSearchResultsTab currentTab = _getCurrentTab();

    if (searchQuery.length <= 2) {
      if (searchQuery.startsWith('#') &&
          currentTab != OFUserSearchResultsTab.hashtags) {
        _setCurrentTab(OFUserSearchResultsTab.hashtags);
      } else if (searchQuery.startsWith('@') &&
          currentTab != OFUserSearchResultsTab.users) {
        _setCurrentTab(OFUserSearchResultsTab.users);
      }
    }
  }

  void _setCurrentTab(OFUserSearchResultsTab tab) {
    int tabIndex = OFUserSearchResultsTab.values.indexOf(tab);
    setState(() {
      _tabController.index = tabIndex;
    });
  }

  OFUserSearchResultsTab _getCurrentTab() {
    return OFUserSearchResultsTab.values[_tabController.index];
  }
}

enum OFUserSearchResultsTab { users, hashtags }
