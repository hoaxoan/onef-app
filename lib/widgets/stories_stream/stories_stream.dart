import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/widgets/buttons/stream_load_more_button.dart';
import 'package:onef/widgets/stories_stream/widgets/new_story.dart';
import 'package:onef/widgets/story/story.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/tiles/loading_indicator_tile.dart';
import 'package:onef/widgets/tiles/retry_tile.dart';

var rng = new Random();

class OFStoriesStream extends StatefulWidget {
  final List<Widget> prependedItems;
  final OFStoriesStreamRefresher refresher;
  final OFStoriesStreamOnScrollLoader onScrollLoader;
  final ScrollController scrollController;
  final OFStoriesStreamController controller;
  final List<Story> initialStories;
  final String streamIdentifier;
  final ValueChanged<List<Story>> onStoriesRefreshed;
  final bool refreshOnCreate;
  final OFStoriesStreamSecondaryRefresher secondaryRefresher;
  final OFStoriesStreamStatusIndicatorBuilder statusIndicatorBuilder;
  final OFStoryDisplayContext displayContext;
  final OFStoriesStreamPostBuilder storyBuilder;
  final Function(ScrollPosition) onScrollCallback;
  final double refreshIndicatorDisplacement;
  final int onScrollLoadMoreLimit;
  final String onScrollLoadMoreLimitLoadMoreText;

  const OFStoriesStream({
    Key key,
    this.prependedItems,
    @required this.refresher,
    @required this.onScrollLoader,
    this.onScrollCallback,
    this.controller,
    this.initialStories,
    @required this.streamIdentifier,
    this.onStoriesRefreshed,
    this.refreshOnCreate = true,
    this.refreshIndicatorDisplacement = 40.0,
    this.secondaryRefresher,
    this.storyBuilder,
    this.statusIndicatorBuilder,
    this.onScrollLoadMoreLimit,
    this.onScrollLoadMoreLimitLoadMoreText,
    this.displayContext = OFStoryDisplayContext.timelinePosts,
    this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFStoriesStreamState();
  }
}

class OFStoriesStreamState extends State<OFStoriesStream>
    with SingleTickerProviderStateMixin {
  List<Story> _stories;
  bool _needsBootstrap;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;
  ScrollController _streamScrollController;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  OFStoriesStreamStatus _status;

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
    _stories = widget.initialStories != null ? widget.initialStories.toList() : [];
    if (_stories.isNotEmpty) _shouldHideStackedLoadingScreen = false;
    _needsBootstrap = true;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _status = OFStoriesStreamStatus.idle;
    _streamScrollController = widget.scrollController ?? ScrollController();
    _streamScrollController.addListener(_onScroll);
    _streamUniqueIdentifier = '${widget.streamIdentifier}_${rng.nextInt(1000).toString()}';

    _hideOverlayAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0).animate(_hideOverlayAnimationController);
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
      _status = OFStoriesStreamStatus.refreshing;
      Future.delayed(Duration(milliseconds: 100), () {
        _refresh();
      });
    }
    // Pretty darn ugly.... How can we do better?
    if (widget.displayContext == OFStoryDisplayContext.topPosts && _stories.isNotEmpty) {
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
      onRefresh: _refreshStories,
      child: _buildStream(),
    );
  }

  Widget _buildStream() {
    List<Widget> streamItems = [];
    bool hasPrependedItems =widget.prependedItems != null && widget.prependedItems.isNotEmpty;
    if (hasPrependedItems) streamItems.addAll(widget.prependedItems);

    if (_stories.isEmpty) {
      OFStoriesStreamStatusIndicatorBuilder statusIndicatorBuilder = widget.statusIndicatorBuilder ?? defaultStatusIndicatorBuilder;

      streamItems.add(statusIndicatorBuilder(
        context: context,
        streamStatus: _status,
        streamRefresher: _refresh,
        streamPrependedItems: widget.prependedItems,
      ));
    } else {
      streamItems.addAll(_buildStreamStories());
      if (_status != OFStoriesStreamStatus.idle)
        streamItems.add(_buildStatusTile());
    }

    return Stack(
      children: _getStoriesStreamStackChildren(streamItems),
    );
  }

  List<Widget> _getStoriesStreamStackChildren(List<Widget> streamItems) {
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

  List<Widget> _buildStreamStories() {
    OFStoriesStreamPostBuilder storyBuilder = widget.storyBuilder ?? _defaultStreamStoryBuilder;

    return _stories.map((Story story) {
      if (_stories.isNotEmpty && story.id == _stories.last.id) {
        _hideInitialPostsLoadingOverlay();
      }

      String storyIdentifier = _makeStoryUniqueIdentifier(story);

      return storyBuilder(
          context: context,
          story: story,
          storyIdentifier: storyIdentifier,
          displayContext: widget.displayContext,
          onStoryDeleted: _onStoryDeleted);
    }).toList();
  }

  Widget _defaultStreamStoryBuilder({
    BuildContext context,
    Story story,
    OFStoryDisplayContext displayContext,
    String storyIdentifier,
    ValueChanged<Story> onStoryDeleted,
  }) {
    return OFStory(
      story,
      key: Key(storyIdentifier),
      onStoryDeleted: onStoryDeleted,
      inViewId: storyIdentifier,
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
      case OFStoriesStreamStatus.loadingMore:
        return Padding(
          key: statusKey,
          padding: const EdgeInsets.all(20),
          child: const OFLoadingIndicatorTile(),
        );
        break;
      case OFStoriesStreamStatus.loadingMoreFailed:
        return OFRetryTile(
          key: statusKey,
          onWantsToRetry: _loadMoreStories,
        );
        break;
      case OFStoriesStreamStatus.noMoreToLoad:
        return ListTile(
          key: statusKey,
          title: OFSecondaryText(
            _localizationService.posts_stream__status_tile_no_more_to_load,
            textAlign: TextAlign.center,
          ),
        );
      case OFStoriesStreamStatus.onScrollLoadMoreLimitReached:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OFStreamLoadMoreButton(
            onPressed: _removeOnScrollLoadMoreLimit,
            text: widget.onScrollLoadMoreLimitLoadMoreText,
            key: statusKey,
          ),
        );
      case OFStoriesStreamStatus.empty:
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

  void _addStoryToTop(Story story) {
    setState(() {
      this._stories.insert(0, story);
      if (this._status == OFStoriesStreamStatus.empty)
        _setStatus(OFStoriesStreamStatus.idle);
    });
  }

  void _onScroll() {
    if (widget.onScrollCallback != null && _shouldHideStackedLoadingScreen) {
      // trigger this callback only after loading overlay is hidden
      // so that its not registered as a manual scroll
      widget.onScrollCallback(_streamScrollController.position);
    }

    if (_status == OFStoriesStreamStatus.loadingMore ||
        _status == OFStoriesStreamStatus.noMoreToLoad) return;

    if (_streamScrollController.position.pixels >
        _streamScrollController.position.maxScrollExtent * 0.1) {
      _loadMoreStories();
    }
  }

  void _ensureNoRefreshStoriesInProgress() {
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

  Future<void> _refreshStories() async {
    debugLog('Refreshing stories');
    _ensureNoRefreshStoriesInProgress();
    _setStatus(OFStoriesStreamStatus.refreshing);
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
      List<Story> stories = results[0];

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          stories.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        stories = stories.sublist(0, widget.onScrollLoadMoreLimit - 1);
        _setStatus(OFStoriesStreamStatus.onScrollLoadMoreLimitReached);
      } else if (stories.length == 0) {
        _setStatus(OFStoriesStreamStatus.empty);
      } else {
        _setStatus(OFStoriesStreamStatus.idle);
      }
      _setStories(stories);
      if (widget.onStoriesRefreshed != null) widget.onStoriesRefreshed(stories);
    } catch (error) {
      _setStatus(OFStoriesStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _refreshOperation = null;
      _secondaryRefresherOperation = null;
    }
  }

  void _removeOnScrollLoadMoreLimit() {
    _onScrollLoadMoreLimitRemoved = true;
    _setStatus(OFStoriesStreamStatus.idle);
    _loadMoreStories();
  }

  Future _loadMoreStories() async {
    if (_status == OFStoriesStreamStatus.refreshing ||
        _status == OFStoriesStreamStatus.noMoreToLoad ||
        _status == OFStoriesStreamStatus.loadingMore ||
        _status == OFStoriesStreamStatus.onScrollLoadMoreLimitReached ||
        _stories.isEmpty) return null;

    if (!_onScrollLoadMoreLimitRemoved &&
        (widget.onScrollLoadMoreLimit != null &&
            _stories.length >= widget.onScrollLoadMoreLimit)) {
      debugLog('Load more limit reached');
      _setStatus(OFStoriesStreamStatus.onScrollLoadMoreLimitReached);
      return;
    }

    debugLog('Loading more stories');
    _ensureNoLoadMoreInProgress();
    _setStatus(OFStoriesStreamStatus.loadingMore);

    try {
      _loadMoreOperation =
          CancelableOperation.fromFuture(widget.onScrollLoader(_stories));

      List<Story> moreStories = await _loadMoreOperation.value;

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          _stories.length + moreStories.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        if (moreStories.length == 0) return;
        moreStories = moreStories.sublist(0, widget.onScrollLoadMoreLimit - _stories.length);
        _setStatus(OFStoriesStreamStatus.onScrollLoadMoreLimitReached);
      } else if (moreStories.length == 0) {
        _setStatus(OFStoriesStreamStatus.noMoreToLoad);
      } else {
        _setStatus(OFStoriesStreamStatus.idle);
        _addStories(moreStories);
      }
    } catch (error) {
      _setStatus(OFStoriesStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }
  }

  void _onStoryDeleted(Story deletedStory) {
    setState(() {
      _stories.remove(deletedStory);
      if (_stories.isEmpty) _setStatus(OFStoriesStreamStatus.empty);
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

  void _setStories(List<Story> stories) {
    setState(() {
      _stories = stories;
    });
  }

  void _addStories(List<Story> stories) {
    setState(() {
      _stories.addAll(stories);
    });
  }

  void _setStatus(OFStoriesStreamStatus status) {
    setState(() {
      _status = status;
    });
  }

  void debugLog(String log) {
    //debugPrint('OBPostsStream:${widget.streamIdentifier}: $log');
  }

  String _makeStoryUniqueIdentifier(Story story) {
    return '${_streamUniqueIdentifier}_${story.id.toString()}';
  }
}

class OFStoriesStreamController {
  OFStoriesStreamState _state;

  /// Register the OBHomePostsState to the controller
  void attach(OFStoriesStreamState state) {
    assert(state != null, 'Cannot attach to empty state');
    _state = state;
  }

  void scrollToTop({bool skipRefresh = false}) {
    _state._scrollToTop(skipRefresh: skipRefresh);
  }

  void addStoryToTop(Story story) {
    _state._addStoryToTop(story);
  }

  Future refreshStories() {
    return _state._refreshStories();
  }

  Future refresh() {
    return _state._refresh();
  }

  bool isAttached() {
    return _state != null;
  }
}

enum OFStoriesStreamStatus {
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
    OFStoriesStreamStatus streamStatus,
    List<Widget> streamPrependedItems,
    Function streamRefresher}) {
  return OFStoriesStreamNewStory(
    streamStatus: streamStatus,
    streamPrependedItems: streamPrependedItems,
    streamRefresher: streamRefresher,
  );
}

typedef Future<List<Story>> OFStoriesStreamRefresher<Story>();
typedef Future<List<Story>> OFStoriesStreamOnScrollLoader<T>(List<Story> stories);
typedef Future OFStoriesStreamSecondaryRefresher();

typedef OFStoriesStreamStatusIndicatorBuilder = Widget Function(
    {@required BuildContext context,
    @required OFStoriesStreamStatus streamStatus,
    @required List<Widget> streamPrependedItems,
    @required Function streamRefresher});

typedef Widget OFStoriesStreamPostBuilder(
    {BuildContext context,
    Story story,
    OFStoryDisplayContext displayContext,
    String storyIdentifier,
    ValueChanged<Story> onStoryDeleted});