import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:onef/models/note.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/widgets/buttons/stream_load_more_button.dart';
import 'package:onef/widgets/note/note.dart';
import 'package:onef/widgets/notes_stream/widgets/dr_hoo.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/tiles/loading_indicator_tile.dart';
import 'package:onef/widgets/tiles/retry_tile.dart';

var rng = new Random();

class OFNotesStream extends StatefulWidget {
  final List<Widget> prependedItems;
  final OFNotesStreamRefresher refresher;
  final OFNotesStreamOnScrollLoader onScrollLoader;
  final OFNotesStreamController controller;
  final List<Note> initialNotes;
  final String streamIdentifier;
  final ValueChanged<List<Note>> onNotesRefreshed;
  final bool refreshOnCreate;
  final OFNotesStreamSecondaryRefresher secondaryRefresher;
  final OFNotesStreamStatusIndicatorBuilder statusIndicatorBuilder;
  final bool isTopNotesStream;
  final OFNotesStreamNoteBuilder noteBuilder;
  final Function(ScrollPosition) onScrollCallback;
  final double refreshIndicatorDisplacement;
  final int onScrollLoadMoreLimit;
  final String onScrollLoadMoreLimitLoadMoreText;

  const OFNotesStream({
    Key key,
    this.prependedItems,
    @required this.refresher,
    @required this.onScrollLoader,
    this.onScrollCallback,
    this.controller,
    this.initialNotes,
    @required this.streamIdentifier,
    this.onNotesRefreshed,
    this.refreshOnCreate = true,
    this.refreshIndicatorDisplacement = 40.0,
    this.secondaryRefresher,
    this.isTopNotesStream = false,
    this.noteBuilder,
    this.statusIndicatorBuilder,
    this.onScrollLoadMoreLimit,
    this.onScrollLoadMoreLimitLoadMoreText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFNotesStreamState();
  }
}

class OFNotesStreamState extends State<OFNotesStream>
    with SingleTickerProviderStateMixin {
  List<Note> _notes;
  bool _needsBootstrap;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;
  ScrollController _streamScrollController;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  OFNotesStreamStatus _status;

  CancelableOperation _refreshOperation;
  CancelableOperation _secondaryRefresherOperation;
  CancelableOperation _loadMoreOperation;
  CancelableOperation _cacheNotesInStorage;

  AnimationController _hideOverlayAnimationController;
  Animation<double> _animation;
  bool _shouldHideStackedLoadingScreen = true;
  bool _onScrollLoadMoreLimitRemoved;

  String _streamUniqueIdentifier;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.attach(this);
    _notes = widget.initialNotes != null ? widget.initialNotes.toList() : [];
    if (_notes.isNotEmpty) _shouldHideStackedLoadingScreen = false;
    _needsBootstrap = true;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _status = OFNotesStreamStatus.idle;
    _streamScrollController = ScrollController();
    _streamScrollController.addListener(_onScroll);
    _streamUniqueIdentifier =
        '${widget.streamIdentifier}_${rng.nextInt(1000).toString()}';

    _hideOverlayAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0)
        .animate(_hideOverlayAnimationController);
    _onScrollLoadMoreLimitRemoved = true;
    _animation.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _streamScrollController.removeListener(_onScroll);
    _secondaryRefresherOperation?.cancel();
    _refreshOperation?.cancel();
    _loadMoreOperation?.cancel();
    _cacheNotesInStorage?.cancel();
  }

  void _bootstrap() {
    if (widget.refreshOnCreate) {
      _status = OFNotesStreamStatus.refreshing;
      Future.delayed(Duration(milliseconds: 100), () {
        _refresh();
      });
    }
    if (widget.isTopNotesStream && _notes.isNotEmpty) {
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
      onRefresh: _refreshNotes,
      child: _buildStream(),
    );
  }

  Widget _buildStream() {
    List<Widget> streamItems = [];
    bool hasPrependedItems =
        widget.prependedItems != null && widget.prependedItems.isNotEmpty;
    if (hasPrependedItems) streamItems.addAll(widget.prependedItems);

    if (_notes.isEmpty) {
      OFNotesStreamStatusIndicatorBuilder statusIndicatorBuilder =
          widget.statusIndicatorBuilder ?? defaultStatusIndicatorBuilder;

      streamItems.add(statusIndicatorBuilder(
        context: context,
        streamStatus: _status,
        streamRefresher: _refresh,
        streamPrependedItems: widget.prependedItems,
      ));
    } else {
      streamItems.addAll(_buildStreamNotes());
      if (_status != OFNotesStreamStatus.idle)
        streamItems.add(_buildStatusTile());
    }

    return Stack(
      children: _getNotesStreamStackChildren(streamItems),
    );
  }

  Widget _getChild(BuildContext context, List<Widget> streamItems, int index) {
    return streamItems[index];
  }

  List<Widget> _getNotesStreamStackChildren(List<Widget> streamItems) {
    var theme = _themeService.getActiveTheme();
    var primaryColor = _themeValueParserService.parseColor(theme.primaryColor);
    List<Widget> _stackChildren = [];

    _stackChildren.add(Container(
        child: StaggeredGridView.countBuilder(
      padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
      itemCount: streamItems.length,
      crossAxisCount: 2,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      itemBuilder: (context, index) => _getChild(context, streamItems, index),
      staggeredTileBuilder: (index) => new StaggeredTile.fit(1),
    )));

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

  List<Widget> _buildStreamNotes() {
    OFNotesStreamNoteBuilder noteBuilder =
        widget.noteBuilder ?? _defaultStreamNoteBuilder;

    return _notes.map((Note note) {
      if (_notes.isNotEmpty && note.id == _notes.last.id) {
        _hideInitialNotesLoadingOverlay();
      }

      String noteIdentifier = _makeNoteUniqueIdentifier(note);

      return noteBuilder(
          context: context,
          note: note,
          noteIdentifier: noteIdentifier,
          onNoteDeleted: _onNoteDeleted);
    }).toList();
  }

  Widget _defaultStreamNoteBuilder({
    BuildContext context,
    Note note,
    String noteIdentifier,
    ValueChanged<Note> onNoteDeleted,
  }) {
    return OFNote(
      note,
      key: Key(noteIdentifier),
      onNoteDeleted: onNoteDeleted,
      inViewId: noteIdentifier,
      isTopNote: widget.isTopNotesStream,
    );
  }

  void _hideInitialNotesLoadingOverlay() {
    Future.delayed(Duration(milliseconds: 0),
        () => _hideOverlayAnimationController.forward());
  }

  Widget _buildStatusTile() {
    Widget statusTile;
    Key statusKey = Key('${_streamUniqueIdentifier}_status_tile');

    switch (_status) {
      case OFNotesStreamStatus.loadingMore:
        return Padding(
          key: statusKey,
          padding: const EdgeInsets.all(20),
          child: const OFLoadingIndicatorTile(),
        );
        break;
      case OFNotesStreamStatus.loadingMoreFailed:
        return OFRetryTile(
          key: statusKey,
          onWantsToRetry: _loadMoreNotes,
        );
        break;
      case OFNotesStreamStatus.noMoreToLoad:
        return ListTile(
          key: statusKey,
          title: OFSecondaryText(
            _localizationService.posts_stream__status_tile_no_more_to_load,
            textAlign: TextAlign.center,
          ),
        );
      case OFNotesStreamStatus.onScrollLoadMoreLimitReached:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OFStreamLoadMoreButton(
            onPressed: _removeOnScrollLoadMoreLimit,
            text: widget.onScrollLoadMoreLimitLoadMoreText,
            key: statusKey,
          ),
        );
      case OFNotesStreamStatus.empty:
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

  void _addNoteToTop(Note note) {
    setState(() {
      this._notes.insert(0, note);
      if (this._status == OFNotesStreamStatus.empty)
        _setStatus(OFNotesStreamStatus.idle);
    });
  }

  void _onScroll() {
    if (widget.onScrollCallback != null && _shouldHideStackedLoadingScreen) {
      // trigger this callback only after loading overlay is hidden
      // so that its not registered as a manual scroll
      widget.onScrollCallback(_streamScrollController.position);
    }

    if (_status == OFNotesStreamStatus.loadingMore ||
        _status == OFNotesStreamStatus.noMoreToLoad) return;

    if (_streamScrollController.position.pixels >
        _streamScrollController.position.maxScrollExtent * 0.1) {
      _loadMoreNotes();
    }
  }

  void _ensureNoRefreshNotesInProgress() {
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

  Future<void> _refreshNotes() async {
    debugLog('Refreshing notes');
    _ensureNoRefreshNotesInProgress();
    _setStatus(OFNotesStreamStatus.refreshing);
    _onScrollLoadMoreLimitRemoved = true;
    try {
      _refreshOperation = CancelableOperation.fromFuture(widget.refresher());

      List<Future> refreshFutures = [_refreshOperation.value];

      if (widget.secondaryRefresher != null) {
        _secondaryRefresherOperation =
            CancelableOperation.fromFuture(widget.secondaryRefresher());
        refreshFutures.add(_secondaryRefresherOperation.value);
      }

      List<dynamic> results = await Future.wait(refreshFutures);
      List<Note> notes = results[0];

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          notes.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        notes = notes.sublist(0, widget.onScrollLoadMoreLimit - 1);
        _setStatus(OFNotesStreamStatus.onScrollLoadMoreLimitReached);
      } else if (notes.length == 0) {
        _setStatus(OFNotesStreamStatus.empty);
      } else {
        _setStatus(OFNotesStreamStatus.idle);
      }
      _setNotes(notes);
      if (widget.onNotesRefreshed != null) widget.onNotesRefreshed(notes);
    } catch (error) {
      _setStatus(OFNotesStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _refreshOperation = null;
      _secondaryRefresherOperation = null;
    }
  }

  void _removeOnScrollLoadMoreLimit() {
    _onScrollLoadMoreLimitRemoved = true;
    _setStatus(OFNotesStreamStatus.idle);
    _loadMoreNotes();
  }

  Future _loadMoreNotes() async {
    if (_status == OFNotesStreamStatus.refreshing ||
        _status == OFNotesStreamStatus.noMoreToLoad ||
        _status == OFNotesStreamStatus.loadingMore ||
        _status == OFNotesStreamStatus.onScrollLoadMoreLimitReached ||
        _notes.isEmpty) return null;

    if (!_onScrollLoadMoreLimitRemoved &&
        (widget.onScrollLoadMoreLimit != null &&
            _notes.length >= widget.onScrollLoadMoreLimit)) {
      debugLog('Load more limit reached');
      _setStatus(OFNotesStreamStatus.onScrollLoadMoreLimitReached);
      return;
    }

    debugLog('Loading more notes');
    _ensureNoLoadMoreInProgress();
    _setStatus(OFNotesStreamStatus.loadingMore);

    try {
      _loadMoreOperation =
          CancelableOperation.fromFuture(widget.onScrollLoader(_notes));

      List<Note> moreNotes = await _loadMoreOperation.value;

      if (!_onScrollLoadMoreLimitRemoved &&
          widget.onScrollLoadMoreLimit != null &&
          _notes.length + moreNotes.length > widget.onScrollLoadMoreLimit) {
        // Slice the posts to be within the limit
        if (moreNotes.length == 0) return;
        moreNotes =
            moreNotes.sublist(0, widget.onScrollLoadMoreLimit - _notes.length);
        _setStatus(OFNotesStreamStatus.onScrollLoadMoreLimitReached);
      } else if (moreNotes.length == 0) {
        _setStatus(OFNotesStreamStatus.noMoreToLoad);
      } else {
        _setStatus(OFNotesStreamStatus.idle);
        _addNotes(moreNotes);
      }
    } catch (error) {
      _setStatus(OFNotesStreamStatus.loadingMoreFailed);
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }
  }

  void _onNoteDeleted(Note deletedNote) {
    setState(() {
      _notes.remove(deletedNote);
      if (_notes.isEmpty) _setStatus(OFNotesStreamStatus.empty);
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

  void _setNotes(List<Note> notes) {
    setState(() {
      _notes = notes;
    });
  }

  void _addNotes(List<Note> notes) {
    setState(() {
      _notes.addAll(notes);
    });
  }

  void _setStatus(OFNotesStreamStatus status) {
    setState(() {
      _status = status;
    });
  }

  void debugLog(String log) {
    //debugPrint('OFNotesStream:${widget.streamIdentifier}: $log');
  }

  String _makeNoteUniqueIdentifier(Note note) {
    return '${_streamUniqueIdentifier}_${note.id.toString()}';
  }
}

class OFNotesStreamController {
  OFNotesStreamState _state;

  /// Register the OBHomePostsState to the controller
  void attach(OFNotesStreamState state) {
    assert(state != null, 'Cannot attach to empty state');
    _state = state;
  }

  void scrollToTop({bool skipRefresh = false}) {
    _state._scrollToTop(skipRefresh: skipRefresh);
  }

  void addNoteToTop(Note note) {
    _state._addNoteToTop(note);
  }

  Future refreshNotes() {
    return _state._refreshNotes();
  }

  Future refresh() {
    return _state._refresh();
  }

  bool isAttached() {
    return _state != null;
  }
}

enum OFNotesStreamStatus {
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
    OFNotesStreamStatus streamStatus,
    List<Widget> streamPrependedItems,
    Function streamRefresher}) {
  return OFNotesStreamDrHoo(
    streamStatus: streamStatus,
    streamPrependedItems: streamPrependedItems,
    streamRefresher: streamRefresher,
  );
}

typedef Future<List<Note>> OFNotesStreamRefresher<Note>();
typedef Future<List<Note>> OFNotesStreamOnScrollLoader<T>(List<Note> notes);
typedef Future OFNotesStreamSecondaryRefresher();

typedef OFNotesStreamStatusIndicatorBuilder = Widget Function(
    {@required BuildContext context,
    @required OFNotesStreamStatus streamStatus,
    @required List<Widget> streamPrependedItems,
    @required Function streamRefresher});

typedef Widget OFNotesStreamNoteBuilder(
    {BuildContext context,
    Note note,
    String noteIdentifier,
    ValueChanged<Note> onNoteDeleted});
