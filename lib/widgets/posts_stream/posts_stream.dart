import 'dart:math';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/widgets/buttons/stream_load_more_button.dart';
import 'package:onef/widgets/post/post.dart';
import 'package:onef/widgets/posts_stream/widgets/dr_hoo.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/tiles/loading_indicator_tile.dart';
import 'package:onef/widgets/tiles/retry_tile.dart';

var rng = new Random();

class OFPostsStream extends StatefulWidget {
  final List<Widget> prependedItems;
  final OFPostsStreamRefresher refresher;
  final OFPostsStreamOnScrollLoader onScrollLoader;
  final ScrollController scrollController;
  final OFPostsStreamController controller;
  final List<Post> initialPosts;
  final String streamIdentifier;
  final ValueChanged<List<Post>> onPostsRefreshed;
  final bool refreshOnCreate;
  final OFPostsStreamSecondaryRefresher secondaryRefresher;
  final OFPostsStreamStatusIndicatorBuilder statusIndicatorBuilder;
  final OFPostDisplayContext displayContext;
  final OFPostsStreamPostBuilder postBuilder;
  final Function(ScrollPosition) onScrollCallback;
  final double refreshIndicatorDisplacement;
  final int onScrollLoadMoreLimit;
  final String onScrollLoadMoreLimitLoadMoreText;

  const OFPostsStream({
    Key key,
    this.prependedItems,
    @required this.refresher,
    @required this.onScrollLoader,
    this.onScrollCallback,
    this.controller,
    this.initialPosts,
    @required this.streamIdentifier,
    this.onPostsRefreshed,
    this.refreshOnCreate = true,
    this.refreshIndicatorDisplacement = 40.0,
    this.secondaryRefresher,
    this.postBuilder,
    this.statusIndicatorBuilder,
    this.onScrollLoadMoreLimit,
    this.onScrollLoadMoreLimitLoadMoreText,
    this.displayContext = OFPostDisplayContext.timelinePosts,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFPostsStreamState();
  }
}

class OFPostsStreamState extends State<OFPostsStream>
    with SingleTickerProviderStateMixin {
  List<Post> _posts;
  bool _needsBootstrap;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;
  ScrollController _streamScrollController;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  OFPostsStreamStatus _status;

  CancelableOperation _refreshOperation;
  CancelableOperation _secondaryRefresherOperation;
  CancelableOperation _loadMoreOperation;
  CancelableOperation _cachePostsInStorage;

  AnimationController _hideOverlayAnimationController;
  Animation<double> _animation;
  bool _shouldHideStackedLoadingScreen = true;
  bool _onScrollLoadMoreLimitRemoved;

  String _streamUniqueIdentifier;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.attach(this);
    _posts = widget.initialPosts != null ? widget.initialPosts.toList() : [];
    if (_posts.isNotEmpty) _shouldHideStackedLoadingScreen = false;
    _needsBootstrap = true;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _status = OFPostsStreamStatus.idle;
    _streamScrollController = widget.scrollController ?? ScrollController();
    _streamScrollController.addListener(_onScroll);
    _streamUniqueIdentifier =
        '${widget.streamIdentifier}_${rng.nextInt(1000).toString()}';

    _hideOverlayAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0)
        .animate(_hideOverlayAnimationController);
    _onScrollLoadMoreLimitRemoved = false;
    _animation.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _streamScrollController.removeListener(_onScroll);
    _secondaryRefresherOperation?.cancel();
    _refreshOperation?.cancel();
    _loadMoreOperation?.cancel();
    _cachePostsInStorage?.cancel();
  }

  void _bootstrap() {
    if (widget.refreshOnCreate) {
      _status = OFPostsStreamStatus.refreshing;
      Future.delayed(Duration(milliseconds: 100), () {
        _refresh();
      });
    }
    // Pretty darn ugly.... How can we do better?
    if (widget.displayContext == OFPostDisplayContext.topPosts &&
        _posts.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      displacement: widget.refreshIndicatorDisplacement,
      key: _refreshIndicatorKey,
      onRefresh: _refreshPosts,
      child: _buildStream(),
    );
  }

  Widget _buildStream() {
    List<Widget> streamItems = [];
    bool hasPrependedItems =
        widget.prependedItems != null && widget.prependedItems.isNotEmpty;
    if (hasPrependedItems) streamItems.addAll(widget.prependedItems);

    if (_posts.isEmpty) {
      OFPostsStreamStatusIndicatorBuilder statusIndicatorBuilder =
          widget.statusIndicatorBuilder ?? defaultStatusIndicatorBuilder;

      streamItems.add(statusIndicatorBuilder(
        context: context,
        streamStatus: _status,
        streamRefresher: _refresh,
        streamPrependedItems: widget.prependedItems,
      ));
    } else {
      streamItems.addAll(_buildStreamPosts());
      if (_status != OFPostsStreamStatus.idle)
        streamItems.add(_buildStatusTile());
    }

    return Stack(
      children: _getPostsStreamStackChildren(streamItems),
    );
  }

  List<Widget> _getPostsStreamStackChildren(List<Widget> streamItems) {
    var theme = _themeService.getActiveTheme();
    var primaryColor = _themeValueParserService.parseColor(theme.primaryColor);
    List<Widget> _stackChildren = [];

    _stackChildren.add(InViewNotifierList(
      key: Key(_streamUniqueIdentifier),
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(0),
      controller: _streamScrollController,
      isInViewPortCondition: _checkTimelineItemIsInViewport,
      children: streamItems,
    ));

    if (!_shouldHideStackedLoadingScreen) {
      _stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0,
        child: IgnorePointer(
            ignoring: true,
            child: FadeTransition(
              opacity: _animation,
              child: DecoratedBox(
                decoration: BoxDecoration(color: primaryColor),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            )),
      ));
    }
    return _stackChildren;
  }

  List<Widget> _buildStreamPosts() {
    OFPostsStreamPostBuilder postBuilder =
        widget.postBuilder ?? _defaultStreamPostBuilder;

    return _posts.map((Post post) {
      if (_posts.isNotEmpty && post.id == _posts.last.id) {
        _hideInitialPostsLoadingOverlay();
      }

      String postIdentifier = _makePostUniqueIdentifier(post);

      return postBuilder(
          context: context,
          post: post,
          postIdentifier: postIdentifier,
          displayContext: widget.displayContext,
          onPostDeleted: _onPostDeleted);
    }).toList();
  }

  Widget _defaultStreamPostBuilder({
    BuildContext context,
    Post post,
    OFPostDisplayContext displayContext,
    String postIdentifier,
    ValueChanged<Post> onPostDeleted,
  }) {
    return OFPost(
      post,
      key: Key(postIdentifier),
      onPostDeleted: onPostDeleted,
      inViewId: postIdentifier,
      displayContext: displayContext,
    );
  }

  void _hideInitialPostsLoadingOverlay() {
    Future.delayed(Duration(milliseconds: 0),
        () => _hideOverlayAnimationController.forward());
  }

  Widget _buildStatusTile() {
    Widget statusTile;
    Key statusKey = Key('${_streamUniqueIdentifier}_status_tile');

    switch (_status) {
      case OFPostsStreamStatus.loadingMore:
        return Padding(
          key: statusKey,
          padding: const EdgeInsets.all(20),
          child: const OFLoadingIndicatorTile(),
        );
        break;
      case OFPostsStreamStatus.loadingMoreFailed:
        return OFRetryTile(
          key: statusKey,
          onWantsToRetry: _loadMorePosts,
        );
        break;
      case OFPostsStreamStatus.noMoreToLoad:
        return ListTile(
          key: statusKey,
          title: OFSecondaryText(
            _localizationService.posts_stream__status_tile_no_more_to_load,
            textAlign: TextAlign.center,
          ),
        );
      case OFPostsStreamStatus.onScrollLoadMoreLimitReached:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OFStreamLoadMoreButton(
            onPressed: _removeOnScrollLoadMoreLimit,
            text: widget.onScrollLoadMoreLimitLoadMoreText,
            key: statusKey,
          ),
        );
      case OFPostsStreamStatus.empty:
        return ListTile(
          key: statusKey,
          title: OFSecondaryText(
            _localizationService.posts_stream__status_tile_empty,
            textAlign: TextAlign.center,
          ),
        );
      default:
    }

    return statusTile;
  }

  bool _checkTimelineItemIsInViewport(
    double deltaTop,
    double deltaBottom,
    double viewPortDimension,
  ) {
    return deltaTop < (0.5 * viewPortDimension) &&
        deltaBottom > (0.5 * viewPortDimension);
  }

  void _onAnimationStatusChanged(status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _shouldHideStackedLoadingScreen = true;
      });
    }
  }

  void _scrollToTop({bool skipRefresh = false}) {
    if (_streamScrollController.hasClients) {
      if (_streamScrollController.offset == 0 && !skipRefresh) {
        _refreshIndicatorKey.currentState.show();
      }

      _streamScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _scrollToBottom() {
    var position = _streamScrollController.position.maxScrollExtent;
    _streamScrollController.jumpTo(position);
  }

  void _addPostToTop(Post post) {
    setState(() {
      this._posts.insert(0, post);
      if (this._status == OFPostsStreamStatus.empty)
        _setStatus(OFPostsStreamStatus.idle);
    });
  }

  void _onScroll() {
    if (widget.onScrollCallback != null && _shouldHideStackedLoadingScreen) {
      // trigger this callback only after loading overlay is hidden
      // so that its not registered as a manual scroll
      widget.onScrollCallback(_streamScrollController.position);
    }

    if (_status == OFPostsStreamStatus.loadingMore ||
        _status == OFPostsStreamStatus.noMoreToLoad) return;

    if (_streamScrollController.position.pixels >
        _streamScrollController.position.maxScrollExtent * 0.1) {
      _loadMorePosts();
    }
  }

  void _ensureNoRefreshPostsInProgress() {
    if (_refreshOperation != null) {
      _refreshOperation.cancel();
      _refreshOperation = null;
    }
  }

  void _ensureNoLoadMoreInProgress() {
    if (_loadMoreOperation != null) {
      _loadMoreOperation.cancel();
      _loadMoreOperation = null;
    }
  }

  Future _refresh() {
    return _refreshIndicatorKey?.currentState?.show();
  }

  Future<void> _refreshPosts() async {
    debugLog('Refreshing posts');
    _ensureNoRefreshPostsInProgress();
    _setStatus(OFPostsStreamStatus.refreshing);
    _onScrollLoadMoreLimitRemoved = false;
    try {
      _refreshOperation = CancelableOperation.fromFuture(widget.refresher());

      List<Future> refreshFutures = [_refreshOperation.value];

      if (widget.secondaryRefresher != null) {
        _secondaryRefresherOperation =
            CancelableOperation.fromFuture(widget.secondaryRefresher());
        refreshFutures.add(_secondaryRefresherOperation.value);
      }

      List<dynamic> results = await Future.wait(refreshFutures);
      List<Post> posts = results[0];

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          posts.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        posts = posts.sublist(0, widget.onScrollLoadMoreLimit - 1);
        _setStatus(OFPostsStreamStatus.onScrollLoadMoreLimitReached);
      } else if (posts.length == 0) {
        _setStatus(OFPostsStreamStatus.empty);
      } else {
        _setStatus(OFPostsStreamStatus.idle);
      }
      _setPosts(posts);
      if (widget.onPostsRefreshed != null) widget.onPostsRefreshed(posts);
    } catch (error) {
      _setStatus(OFPostsStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _refreshOperation = null;
      _secondaryRefresherOperation = null;
    }
  }

  void _removeOnScrollLoadMoreLimit() {
    _onScrollLoadMoreLimitRemoved = true;
    _setStatus(OFPostsStreamStatus.idle);
    _loadMorePosts();
  }

  Future _loadMorePosts() async {
    if (_status == OFPostsStreamStatus.refreshing ||
        _status == OFPostsStreamStatus.noMoreToLoad ||
        _status == OFPostsStreamStatus.loadingMore ||
        _status == OFPostsStreamStatus.onScrollLoadMoreLimitReached ||
        _posts.isEmpty) return null;

    if (!_onScrollLoadMoreLimitRemoved &&
        (widget.onScrollLoadMoreLimit != null &&
            _posts.length >= widget.onScrollLoadMoreLimit)) {
      debugLog('Load more limit reached');
      _setStatus(OFPostsStreamStatus.onScrollLoadMoreLimitReached);
      return;
    }

    debugLog('Loading more posts');
    _ensureNoLoadMoreInProgress();
    _setStatus(OFPostsStreamStatus.loadingMore);

    try {
      _loadMoreOperation =
          CancelableOperation.fromFuture(widget.onScrollLoader(_posts));

      List<Post> morePosts = await _loadMoreOperation.value;

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          _posts.length + morePosts.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        if (morePosts.length == 0) return;
        morePosts =
            morePosts.sublist(0, widget.onScrollLoadMoreLimit - _posts.length);
        _setStatus(OFPostsStreamStatus.onScrollLoadMoreLimitReached);
      } else if (morePosts.length == 0) {
        _setStatus(OFPostsStreamStatus.noMoreToLoad);
      } else {
        _setStatus(OFPostsStreamStatus.idle);
        _addPosts(morePosts);
      }
    } catch (error) {
      _setStatus(OFPostsStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }
  }

  void _onPostDeleted(Post deletedPost) {
    setState(() {
      _posts.remove(deletedPost);
      if (_posts.isEmpty) _setStatus(OFPostsStreamStatus.empty);
      if (deletedPost.isCommunityPost())
        deletedPost.community.decrementPostsCount();
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

  void _setPosts(List<Post> posts) {
    setState(() {
      _posts = posts;
    });
  }

  void _addPosts(List<Post> posts) {
    setState(() {
      _posts.addAll(posts);
    });
  }

  void _setStatus(OFPostsStreamStatus status) {
    setState(() {
      _status = status;
    });
  }

  void debugLog(String log) {
    //debugPrint('OBPostsStream:${widget.streamIdentifier}: $log');
  }

  String _makePostUniqueIdentifier(Post post) {
    return '${_streamUniqueIdentifier}_${post.id.toString()}';
  }
}

class OFPostsStreamController {
  OFPostsStreamState _state;

  /// Register the OBHomePostsState to the controller
  void attach(OFPostsStreamState state) {
    assert(state != null, 'Cannot attach to empty state');
    _state = state;
  }

  void scrollToTop({bool skipRefresh = false}) {
    _state._scrollToTop(skipRefresh: skipRefresh);
  }

  void addPostToTop(Post post) {
    _state._addPostToTop(post);
  }

  Future refreshPosts() {
    return _state._refreshPosts();
  }

  Future refresh() {
    return _state._refresh();
  }

  bool isAttached() {
    return _state != null;
  }
}

enum OFPostsStreamStatus {
  refreshing,
  loadingMore,
  loadingMoreFailed,
  noMoreToLoad,
  empty,
  idle,
  onScrollLoadMoreLimitReached
}

Widget defaultStatusIndicatorBuilder(
    {BuildContext context,
    OFPostsStreamStatus streamStatus,
    List<Widget> streamPrependedItems,
    Function streamRefresher}) {
  return OFPostsStreamDrHoo(
    streamStatus: streamStatus,
    streamPrependedItems: streamPrependedItems,
    streamRefresher: streamRefresher,
  );
}

typedef Future<List<Post>> OFPostsStreamRefresher<Post>();
typedef Future<List<Post>> OFPostsStreamOnScrollLoader<T>(List<Post> posts);
typedef Future OFPostsStreamSecondaryRefresher();

typedef OFPostsStreamStatusIndicatorBuilder = Widget Function(
    {@required BuildContext context,
    @required OFPostsStreamStatus streamStatus,
    @required List<Widget> streamPrependedItems,
    @required Function streamRefresher});

typedef Widget OFPostsStreamPostBuilder(
    {BuildContext context,
    Post post,
    OFPostDisplayContext displayContext,
    String postIdentifier,
    ValueChanged<Post> onPostDeleted});
