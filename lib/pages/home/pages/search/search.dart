import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/models/hashtags_list.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/pages/home/pages/search/widgets/search_results.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/search_bar.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';
import 'package:throttling/throttling.dart';

class OFMainSearchPage extends StatefulWidget {
  final OFMainSearchPageController controller;
  final OFSearchPageTab selectedTab;

  const OFMainSearchPage(
      {Key key, this.controller, this.selectedTab = OFSearchPageTab.trending})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFMainSearchPageState();
  }
}

class OFMainSearchPageState extends State<OFMainSearchPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  bool _hasSearch;
  bool _userSearchRequestInProgress;
  bool _hashtagSearchRequestInProgress;
  String _searchQuery;
  List<User> _userSearchResults;
  List<Hashtag> _hashtagSearchResults;
  /*OBTopPostsController _topPostsController;
  OBTrendingPostsController _trendingPostsController;*/
  TabController _tabController;
  AnimationController _animationController;
  Animation<Offset> _offset;
  double _heightTabs;
  double _lastScrollPosition;
  double _extraPaddingForSlidableSection;

  OFUserSearchResultsTab _selectedSearchResultsTab;

  StreamSubscription<UsersList> _getUsersWithQuerySubscription;
  StreamSubscription<HashtagsList> _getHashtagsWithQuerySubscription;

  Throttling _setScrollPositionThrottler;

  static const double OB_BOTTOM_TAB_BAR_HEIGHT = 50.0;
  static const double HEIGHT_SEARCH_BAR = 76.0;
  static const double HEIGHT_TABS_SECTION = 52.0;
  static const double MIN_SCROLL_OFFSET_TO_ANIMATE_TABS = 250.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null)
      widget.controller.attach(context: context, state: this);
/*    _topPostsController = OBTopPostsController();
    _trendingPostsController = OBTrendingPostsController();*/
    _userSearchRequestInProgress = false;
    _hashtagSearchRequestInProgress = false;
    _hasSearch = false;
    _heightTabs = HEIGHT_TABS_SECTION;
    _userSearchResults = [];
    _hashtagSearchResults = [];
    _selectedSearchResultsTab = OFUserSearchResultsTab.users;
    _tabController = new TabController(length: 2, vsync: this);
    _setScrollPositionThrottler =
        new Throttling(duration: Duration(milliseconds: 300));
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0))
        .animate(_animationController);

    switch (widget.selectedTab) {
      case OFSearchPageTab.explore:
        _tabController.index = 1;
        break;
      case OFSearchPageTab.trending:
        _tabController.index = 0;
        break;
      default:
        throw "Unhandled tab index: ${widget.selectedTab}";
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;
    _localizationService = provider.localizationService;
    _themeService = provider.themeService;
    _themeValueParserService = provider.themeValueParserService;

    if (_extraPaddingForSlidableSection == null)
      _extraPaddingForSlidableSection = _getExtraPaddingForSlidableSection();

    return OFCupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: OFPrimaryColorContainer(
        child: Stack(
          children: <Widget>[
            _getIndexedStackWidget(),
            _createSearchBarAndTabsOverlay()
          ],
        ),
      ),
    );
  }

  Widget _getIndexedStackWidget() {
    double slidableSectionHeight = HEIGHT_SEARCH_BAR + HEIGHT_TABS_SECTION;

    return IndexedStack(
      index: _hasSearch ? 1 : 0,
      children: <Widget>[
        SafeArea(
          bottom: false,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: <Widget>[
              /* OBTrendingPosts(
                  controller: _trendingPostsController,
                  onScrollCallback: _onScrollPositionChange,
                  extraTopPadding: slidableSectionHeight),
              OBTopPosts(
                  controller: _topPostsController,
                  onScrollCallback: _onScrollPositionChange,
                  extraTopPadding: slidableSectionHeight),*/
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: HEIGHT_SEARCH_BAR + _extraPaddingForSlidableSection),
          child: OFSearchResults(
            searchQuery: _searchQuery,
            userResults: _userSearchResults,
            userSearchInProgress: _userSearchRequestInProgress,
            hashtagResults: _hashtagSearchResults,
            hashtagSearchInProgress: _hashtagSearchRequestInProgress,
            onUserPressed: _onSearchUserPressed,
            onHashtagPressed: _onSearchHashtagPressed,
            selectedTab: _selectedSearchResultsTab,
            onScroll: _onScrollSearchResults,
            onTabSelectionChanged: _onSearchTabSelectionChanged,
          ),
        ),
      ],
    );
  }

  double _getExtraPaddingForSlidableSection() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);
    // flutter has diff heights for notched phones, see also issues with bottom tab bar
    // iphone with notches have a top/bottom padding
    // this adds 20.0 extra padding for notched phones
    if (existingMediaQuery.padding.top != 0 &&
        existingMediaQuery.padding.bottom != 0) return 20.0;
    return 0.0;
  }

  Widget _createSearchBarAndTabsOverlay() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);

    return Positioned(
        left: 0,
        top: 0,
        height:
            HEIGHT_SEARCH_BAR + _heightTabs + _extraPaddingForSlidableSection,
        width: existingMediaQuery.size.width,
        child: OFCupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: _getSlideTransitionWidget(),
        ));
  }

  Widget _getSlideTransitionWidget() {
    OFTheme theme = _themeService.getActiveTheme();
    Color tabIndicatorColor = _themeValueParserService
        .parseGradient(theme.primaryAccentColor)
        .colors[1];
    Color tabLabelColor =
        _themeValueParserService.parseColor(theme.primaryTextColor);

    return SlideTransition(
      position: _offset,
      child: OFPrimaryColorContainer(
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              OFSearchBar(
                onSearch: _onSearch,
                hintText: _localizationService.user_search__search_text,
              ),
              _hasSearch
                  ? const SizedBox(height: 0)
                  : TabBar(
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(
                          icon: OFIcon(OFIcons.trending),
                        ),
                        Tab(
                          icon: OFIcon(OFIcons.explore),
                        ),
                      ],
                      isScrollable: false,
                      indicatorColor: tabIndicatorColor,
                      labelColor: tabLabelColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScrollPositionChange(ScrollPosition position) {
    bool isScrollingUp =
        position.userScrollDirection == ScrollDirection.forward;
    _hideKeyboard();
    if (position.pixels < (HEIGHT_SEARCH_BAR + HEIGHT_TABS_SECTION)) {
      if (_offset.value.dy == -1.0) _showTabSection();
      return;
    }
    _setScrollPositionThrottler
        .throttle(() => _handleScrollThrottle(position.pixels, isScrollingUp));
  }

  void _handleScrollThrottle(double scrollPixels, bool isScrollingUp) {
    if (_lastScrollPosition != null) {
      double offset = (scrollPixels - _lastScrollPosition).abs();
      if (offset > MIN_SCROLL_OFFSET_TO_ANIMATE_TABS)
        _checkScrollDirectionAndAnimateTabs(isScrollingUp);
    }
    _setScrollPosition(scrollPixels);
  }

  void _checkScrollDirectionAndAnimateTabs(bool isScrollingUp) {
    if (isScrollingUp) {
      _showTabSection();
    } else {
      _hideTabSection();
    }
  }

  void _setScrollPosition(double scrollPixels) {
    setState(() {
      _lastScrollPosition = scrollPixels;
    });
  }

  void _onSearch(String query) {
    _setSearchQuery(query);
    if (query.isEmpty) {
      _setHasSearch(false);
      return;
    }

    if (_hasSearch == false) {
      _setHasSearch(true);
    }

    _searchWithQuery(query);
  }

  void _onScrollSearchResults() {
    _hideKeyboard();
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future<void> _searchWithQuery(String query) {
    String cleanedUpQuery = _cleanUpQuery(query);
    if (cleanedUpQuery.isEmpty) return null;

    return Future.wait([
      _searchForUsersWithQuery(cleanedUpQuery),
      _searchForHashtagsWithQuery(cleanedUpQuery)
    ]);
  }

  final hashtagAndUsernamesRegexp = RegExp(r'^#|@');

  String _cleanUpQuery(String query) {
    String cleanQuery = query;
    if (cleanQuery.startsWith(hashtagAndUsernamesRegexp)) {
      cleanQuery = cleanQuery.substring(1, cleanQuery.length);
    } else if (cleanQuery.startsWith('c/')) {
      cleanQuery = cleanQuery.substring(2, cleanQuery.length);
    }
    return cleanQuery;
  }

  Future<void> _searchForUsersWithQuery(String query) async {
    if (_getUsersWithQuerySubscription != null)
      _getUsersWithQuerySubscription.cancel();

    _setUserSearchRequestInProgress(true);

    _getUsersWithQuerySubscription =
        _userService.getUsersWithQuery(query).asStream().listen(
            (UsersList usersList) {
              _getUsersWithQuerySubscription = null;
              _setUserSearchResults(usersList.users);
            },
            onError: _onError,
            onDone: () {
              _setUserSearchRequestInProgress(false);
            });
  }

  Future<void> _searchForHashtagsWithQuery(String query) async {
    if (_getHashtagsWithQuerySubscription != null)
      _getHashtagsWithQuerySubscription.cancel();

    _setHashtagSearchRequestInProgress(true);

    _getHashtagsWithQuerySubscription =
        _userService.getHashtagsWithQuery(query).asStream().listen(
            (HashtagsList hashtagsList) {
              _setHashtagSearchResults(hashtagsList.hashtags);
            },
            onError: _onError,
            onDone: () {
              _setHashtagSearchRequestInProgress(false);
            });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onSearchTabSelectionChanged(OFUserSearchResultsTab newSelection) {
    _selectedSearchResultsTab = newSelection;
  }

  void _setUserSearchRequestInProgress(bool requestInProgress) {
    setState(() {
      _userSearchRequestInProgress = requestInProgress;
    });
  }

  void _setHashtagSearchRequestInProgress(bool requestInProgress) {
    setState(() {
      _hashtagSearchRequestInProgress = requestInProgress;
    });
  }

  void _hideTabSection() {
    _animationController.forward();
  }

  void _showTabSection() {
    _animationController.reverse();
  }

  void _setHasSearch(bool hasSearch) {
    setState(() {
      _hasSearch = hasSearch;
    });
    _setHeightTabsZero(_hasSearch);
  }

  void _setHeightTabsZero(bool hasSearch) {
    setState(() {
      _heightTabs = hasSearch == true ? 5.0 : HEIGHT_TABS_SECTION;
    });
  }

  void _setSearchQuery(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
    });
  }

  void _setUserSearchResults(List<User> searchResults) {
    setState(() {
      _userSearchResults = searchResults;
    });
  }

  void _setHashtagSearchResults(List<Hashtag> searchResults) {
    setState(() {
      _hashtagSearchResults = searchResults;
    });
  }

  void _onSearchUserPressed(User user) {
    _hideKeyboard();
    //_navigationService.navigateToUserProfile(user: user, context: context);
  }

  void _onSearchHashtagPressed(Hashtag hashtag) {
    _hideKeyboard();
    //_navigationService.navigateToHashtag(hashtag: hashtag, context: context);
  }

  void scrollToTop() {
    /*if (_tabController.index == 0) {
      _trendingPostsController.scrollToTop();
    } else if (_tabController.index == 1) {
      _topPostsController.scrollToTop();
    }*/
  }
}

class OFMainSearchPageController extends PoppablePageController {
  OFMainSearchPageState _state;

  void attach({@required BuildContext context, OFMainSearchPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}

enum OFSearchPageTab { explore, trending }
