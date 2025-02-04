import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:async/async.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_video.dart';
import 'package:onef/models/video_format.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/widgets/video_player/video_player.dart';

class OFPostBodyVideo extends StatefulWidget {
  final double height;
  final double width;
  final Post post;
  final PostVideo postVideo;
  final String inViewId;
  final bool hasExpandButton;
  final bool isConstrained;

  const OFPostBodyVideo(
      {Key key,
      this.post,
      this.postVideo,
      this.inViewId,
      this.height,
      this.width,
      this.hasExpandButton,
      this.isConstrained = false})
      : super(key: key);

  @override
  OFPostVideoState createState() {
    return OFPostVideoState();
  }
}

class OFPostVideoState extends State<OFPostBodyVideo> {
  OFVideoPlayerController _obVideoPlayerController;
  bool _needsBootstrap;
  StreamSubscription _videosSoundSettingsChangeSubscription;
  Navigator _navigator;
  NavigatorObserver _navigatorObserver;
  ModalRoute _route;
  bool _wasPlaying;

  bool _videosAutoPlayAreEnabled;
  StreamSubscription _videosAutoPlayAreEnabledChangeSubscription;

  CancelableOperation _digestInViewStateChangeOperation;

  InViewState _inViewState;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _obVideoPlayerController = OFVideoPlayerController();
    _videosAutoPlayAreEnabled = false;
  }

  @override
  void dispose() {
    super.dispose();
    _videosAutoPlayAreEnabledChangeSubscription?.cancel();
    _videosSoundSettingsChangeSubscription?.cancel();
    _digestInViewStateChangeOperation?.cancel();
    _inViewState?.removeListener(_onInViewStateChanged);
    _navigator.observers.remove(_navigatorObserver);
  }

  void _bootstrap(BuildContext context) async {
    if (widget.inViewId != null) {
      // Subscribe for visibility changes
      _inViewState = InViewNotifierList.of(context);
      _inViewState.addContext(context: context, id: widget.inViewId);
      _inViewState.addListener(_onInViewStateChanged);
    }

    _route = ModalRoute.of(context);
    _navigatorObserver = PostVideoNavigatorObserver(this);
    _navigator = Navigator.of(context).widget;
    _navigator.observers.add(_navigatorObserver);

    // Subscribe for autoplay changes
    var provider = OneFProvider.of(context);
    UserPreferencesService userPreferencesService = provider.userPreferencesService;
    _videosAutoPlayAreEnabled = userPreferencesService.getVideosAutoPlayAreEnabled();

    _videosSoundSettingsChangeSubscription = userPreferencesService
        .videosAutoPlayAreEnabledChange
        .listen(_onVideosAutoPlayAreEnabledChange);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      _bootstrap(context);
      _needsBootstrap = false;
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: _buildVideoPlayer(),
        )
      ],
    );
  }

  Widget _buildVideoPlayer() {
    OFVideoFormat videoFormat =
        widget.postVideo.getVideoFormatOfType(OFVideoFormatType.mp4SD);

    String videoUrl = videoFormat.file;

    return OFVideoPlayer(
      videoUrl: videoUrl,
      thumbnailUrl: widget.postVideo.thumbnail,
      height: widget.height,
      width: widget.width,
      isConstrained: widget.isConstrained,
      controller: _obVideoPlayerController,
    );
  }

  void _onInViewStateChanged() {
    final bool isVideoInView = _inViewState.inView(widget.inViewId);

    _digestInViewStateChangeOperation?.cancel();
    _digestInViewStateChangeOperation = CancelableOperation.fromFuture(
        _digestInViewStateChanged(isVideoInView));
  }

  Future _digestInViewStateChanged(bool isVideoInView) async {
    if (_obVideoPlayerController.hasVideoOpenedInDialog()) return;
    debugLog('Is in View: ${isVideoInView.toString()}');
    if (isVideoInView) {
      if (!_obVideoPlayerController.isPausedDueToInvisibility() &&
          !_obVideoPlayerController.isPausedByUser()) {
        if (_videosAutoPlayAreEnabled) {
          debugLog('Playing as item is in view and allowed by user.');
          _obVideoPlayerController.play();
        }
      }
    } else if (_obVideoPlayerController.isPlaying()) {
      _obVideoPlayerController.pause();
    }
  }

  void _onVideosAutoPlayAreEnabledChange(bool videosAutoPlayAreEnabled) {
    _videosAutoPlayAreEnabled = videosAutoPlayAreEnabled;
  }

  void debugLog(String log) {
    //debugPrint('OBPostBodyVideo: $log');
  }
}

class PostVideoNavigatorObserver extends NavigatorObserver {
  OFPostVideoState _state;

  PostVideoNavigatorObserver(OFPostVideoState state) {
    _state = state;
  }

  @override
  void didPush(Route route, Route previousRoute) {
    if (identical(previousRoute, _state._route)) {
      _state._wasPlaying = _state._obVideoPlayerController.isPlaying();
      if (_state._wasPlaying) {
        debugLog('Pausing video due to another route opened.');
        _state._obVideoPlayerController.pause();
      }
    }
  }

  @override
  void didPop(Route route, Route previousRoute) {
    if (identical(previousRoute, _state._route) &&
        _state != null &&
        _state.mounted &&
        _state._wasPlaying != null && _state._wasPlaying) {
      debugLog('Resuming video as blocking route has been popped.');
      _state._obVideoPlayerController.play();
    }
  }

  void debugLog(String log) {
    debugPrint('PostVideoNavigatorObserver: $log');
  }
}
