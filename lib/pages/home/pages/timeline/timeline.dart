import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/models/follows_list.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/buttons/floating_action_button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/icon_button.dart';
import 'package:onef/widgets/nav_bars/themed_nav_bar.dart';
import 'package:onef/widgets/new_post_data_uploader.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/posts_stream/posts_stream.dart';

class OFTimelinePage extends StatefulWidget {
  final OFTimelinePageController controller;

  OFTimelinePage({
    @required this.controller,
  });

  @override
  OFTimelinePageState createState() {
    return OFTimelinePageState();
  }
}

class OFTimelinePageState extends State<OFTimelinePage>
    with TickerProviderStateMixin {
  OFPostsStreamController _timelinePostsStreamController;
  ScrollController _timelinePostsStreamScrollController;
  ModalService _modalService;
  UserService _userService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  List<Post> _initialPosts;
  List<OFNewPostData> _newPostsData;
  List<Circle> _filteredCircles;
  List<FollowsList> _filteredFollowsLists;

  StreamSubscription _loggedInUserChangeSubscription;

  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  double _hideFloatingButtonTolerance = 10;
  AnimationController _hideFloatingButtonAnimation;
  double _previousScrollPixels;

  @override
  void initState() {
    super.initState();
    _timelinePostsStreamController = OFPostsStreamController();
    _timelinePostsStreamScrollController = ScrollController();
    widget.controller.attach(context: context, state: this);
    _needsBootstrap = true;
    _loggedInUserBootstrapped = false;
    _filteredCircles = [];
    _filteredFollowsLists = [];
    _newPostsData = [];
    _hideFloatingButtonAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFloatingButtonAnimation.forward();

    _previousScrollPixels = 0;

    _timelinePostsStreamScrollController.addListener(() {
      double newScrollPixelPosition =
          _timelinePostsStreamScrollController.position.pixels;
      double scrollPixelDifference =
          _previousScrollPixels - newScrollPixelPosition;

      if (_timelinePostsStreamScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (scrollPixelDifference * -1 > _hideFloatingButtonTolerance) {
          _hideFloatingButtonAnimation.reverse();
        }
      } else {
        if (scrollPixelDifference > _hideFloatingButtonTolerance) {
          _hideFloatingButtonAnimation.forward();
        }
      }

      _previousScrollPixels = newScrollPixelPosition;
    });
  }

  @override
  void dispose() {
    _hideFloatingButtonAnimation.dispose();
    super.dispose();
    _loggedInUserChangeSubscription.cancel();
  }

  void _bootstrap() async {
    _loggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _modalService = provider.modalService;
      _localizationService = provider.localizationService;
      _userService = provider.userService;
      _themeService = provider.themeService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return OFCupertinoPageScaffold(
        backgroundColor: _themeValueParserService
            .parseColor(_themeService.getActiveTheme().primaryColor),
        navigationBar: OFThemedNavigationBar(
            title: 'Home', trailing: _buildFiltersButton()),
        child: Stack(
          children: <Widget>[
            _loggedInUserBootstrapped
                ? OFPostsStream(
                    controller: _timelinePostsStreamController,
                    scrollController: _timelinePostsStreamScrollController,
                    prependedItems: _buildPostsStreamPrependedItems(),
                    streamIdentifier: 'timeline',
                    onScrollLoader: _postsStreamOnScrollLoader,
                    refresher: _postsStreamRefresher,
                    initialPosts: _initialPosts,
                  )
                : const SizedBox(),
            Positioned(
                bottom: 20.0,
                right: 20.0,
                child: Semantics(
                    button: true,
                    label: _localizationService.post__create_new_post_label,
                    child: ScaleTransition(
                        scale: _hideFloatingButtonAnimation,
                        child: OFFloatingActionButton(
                            type: OFButtonType.primary,
                            onPressed: _onCreatePost,
                            child: const OFIcon(OFIcons.createPost,
                                size: OFIconSize.large, color: Colors.white)))))
          ],
        ));
  }

  List<Widget> _buildPostsStreamPrependedItems() {
    return _buildNewPostDataUploaders();
  }

  List<Widget> _buildNewPostDataUploaders() {
    return _newPostsData.map(_buildNewPostDataUploader).toList();
  }

  Widget _buildNewPostDataUploader(OFNewPostData newPostData) {
    return OFNewPostDataUploader(
      key: Key(newPostData.getUniqueKey()),
      data: newPostData,
      onPostPublished: _onNewPostDataUploaderPostPublished,
      onCancelled: _onNewPostDataUploaderCancelled,
    );
  }

  Widget _buildFiltersButton() {
    int filtersCount = countFilters();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
       /* OFBadge(
          count: filtersCount,
        ),*/
        const SizedBox(
          width: 10,
        ),
        OFIconButton(
          OFIcons.filter,
          themeColor: OFIconThemeColor.primaryAccent,
          onPressed: _onWantsFilters,
        )
      ],
    );
  }

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) return;
    List<Post> initialPosts = (await _userService.getStoredFirstPosts()).posts;
    setState(() {
      _loggedInUserBootstrapped = true;
      _initialPosts = initialPosts;
      _loggedInUserChangeSubscription.cancel();
    });
  }

  Future<List<Post>> _postsStreamRefresher() async {
    bool cachePosts = _filteredCircles.isEmpty && _filteredFollowsLists.isEmpty;

    List<Post> posts = (await _userService.getTimelinePosts(
            count: 10,
            circles: _filteredCircles,
            followsLists: _filteredFollowsLists,
            cachePosts: cachePosts))
        .posts;

    return posts;
  }

  Future<List<Post>> _postsStreamOnScrollLoader(List<Post> posts) async {
    Post lastPost = posts.last;
    int lastPostId = lastPost.id;

    List<Post> morePosts = (await _userService.getTimelinePosts(
            maxId: lastPostId,
            circles: _filteredCircles,
            count: 10,
            followsLists: _filteredFollowsLists))
        .posts;

    return morePosts;
  }

  Future<bool> _onCreatePost({String text, File image, File video}) async {
    OFNewPostData createPostData = await _modalService.openCreatePost(text: text, image: image, video: video, context: context);
    if (createPostData != null) {
      addNewPostData(createPostData);
      _timelinePostsStreamController.scrollToTop(skipRefresh: true);

      return true;
    }

    return false;
  }

  Future<void> setFilters(
      {List<Circle> circles, List<FollowsList> followsLists}) async {
    _filteredCircles = circles;
    _filteredFollowsLists = followsLists;
    return _timelinePostsStreamController.refreshPosts();
  }

  Future<void> clearFilters() {
    _filteredCircles = [];
    _filteredFollowsLists = [];
    return _timelinePostsStreamController.refreshPosts();
  }

  List<Circle> getFilteredCircles() {
    return _filteredCircles.toList();
  }

  List<FollowsList> getFilteredFollowsLists() {
    return _filteredFollowsLists.toList();
  }

  int countFilters() {
    return _filteredCircles.length + _filteredFollowsLists.length;
  }

  void _onNewPostDataUploaderCancelled(OFNewPostData newPostData) {
    _removeNewPostData(newPostData);
  }

  void _onNewPostDataUploaderPostPublished(Post publishedPost, OFNewPostData newPostData) {
    _timelinePostsStreamController.addPostToTop(publishedPost);
    _removeNewPostData(newPostData);
  }

  void addNewPostData(OFNewPostData postUploaderData) {
    setState(() {
      this._newPostsData.insert(0, postUploaderData);
    });
  }

  void _removeNewPostData(OFNewPostData postUploaderData) {
    setState(() {
      this._newPostsData.remove(postUploaderData);
    });
  }

  void scrollToTop() {
    _timelinePostsStreamController.scrollToTop();
  }

  void _onWantsFilters() {
    //_modalService.openTimelineFilters(imelineController: widget.controller, context: context);
  }
}

class OFTimelinePageController extends PoppablePageController {
  OFTimelinePageState _state;

  void attach({@required BuildContext context, OFTimelinePageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> setPostFilters(
      {List<Circle> circles, List<FollowsList> followsLists}) async {
    return _state.setFilters(circles: circles, followsLists: followsLists);
  }

  Future<void> clearPostFilters(
      {List<Circle> circles, List<FollowsList> followsLists}) async {
    return _state.setFilters(circles: circles, followsLists: followsLists);
  }

  List<Circle> getFilteredCircles() {
    return _state.getFilteredCircles();
  }

  List<FollowsList> getFilteredFollowsLists() {
    return _state.getFilteredFollowsLists();
  }

  Future<bool> createPost({String text, File image, File video}) {
    return _state._onCreatePost(text: text, image: image, video: video);
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
