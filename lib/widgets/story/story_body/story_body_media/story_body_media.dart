import 'dart:math';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/progress_indicator.dart';

class OFStoryBodyMedia extends StatefulWidget {
  final Story story;
  final String inViewId;

  const OFStoryBodyMedia({Key key, this.story, this.inViewId}) : super(key: key);

  @override
  OFStoryBodyMediaState createState() {
    return OFStoryBodyMediaState();
  }
}

class OFStoryBodyMediaState extends State<OFStoryBodyMedia> {
  UserService _userService;
  LocalizationService _localizationService;
  bool _needsBootstrap;
  String _errorMessage;

  CancelableOperation _retrievePostMediaOperation;
  bool _retrieveStoryMediaInProgress;

  double _mediaHeight;
  double _mediaWidth;
  bool _mediaIsConstrained;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _retrieveStoryMediaInProgress = true;
    _errorMessage = '';
    _mediaIsConstrained = false;
  }

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _retrieveStoryMediaInProgress = true;
    _needsBootstrap = true;
    _errorMessage = '';
  }

  @override
  void dispose() {
    super.dispose();
    _retrievePostMediaOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _localizationService = provider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
          width: _mediaWidth,
          height: _mediaHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: _buildStoryMediaItemsThumbnail(),
              ),
              _errorMessage.isEmpty
                  ? _retrieveStoryMediaInProgress
                      ? const SizedBox()
                      : _buildMediaItems()
                  : Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildErrorMessage(),
                    )
            ],
          )),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(3)),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMediaItems() {
    return StreamBuilder(
      stream: widget.story.updateSubject,
      initialData: widget.story,
      builder: (BuildContext context, AsyncSnapshot<Story> snapshot) {
        List<PostMedia> postMediaItems = widget.story.getMedia();
        return _buildPostMediaItems(postMediaItems);
      },
    );
  }

  Widget _buildStoryMediaItemsThumbnail() {
    String thumbnailUrl = widget.story.mediaThumbnail;

    return TransitionToImage(
      height: _mediaHeight,
      width: _mediaWidth,
      loadingWidget: const Center(
        child: const OFProgressIndicator(),
      ),
      fit: BoxFit.cover,
      alignment: Alignment.center,
      image: AdvancedNetworkImage(thumbnailUrl,
          useDiskCache: true,
          fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png',
          retryLimit: 3,
          timeoutDuration: const Duration(seconds: 5)),
      duration: Duration(milliseconds: 100),
    );
  }

  Widget _buildPostMediaItems(List<PostMedia> postMediaItems) {
    // We support only one atm
    PostMedia postMediaItem = postMediaItems.first;
    return _buildPostMediaItem(postMediaItem);
  }

  Widget _buildPostMediaItem(PostMedia postMediaItem) {
    Widget postMediaItemWidget;

    dynamic postMediaItemContentObject = postMediaItem.contentObject;

    switch (postMediaItemContentObject.runtimeType) {
      case PostImage:
        postMediaItemWidget = OBPostBodyImage(
            postImage: postMediaItemContentObject,
            hasExpandButton: _mediaIsConstrained,
            height: _mediaHeight,
            width: _mediaWidth);
        break;
      case PostVideo:
        postMediaItemWidget = OBPostBodyVideo(
          postVideo: postMediaItemContentObject,
          post: widget.post,
          inViewId: widget.inViewId,
          height: _mediaHeight,
          width: _mediaWidth,
          isConstrained: _mediaIsConstrained,
        );
        break;
      default:
        postMediaItemWidget = Center(
          child: OBText(_localizationService.post_body_media__unsupported),
        );
    }

    return postMediaItemWidget;
  }

  void _bootstrap() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double maxBoxHeight = screenHeight * .70;

    double imageAspectRatio = widget.post.mediaWidth / widget.post.mediaHeight;
    double imageHeight = (screenWidth / imageAspectRatio);
    _mediaHeight = min(imageHeight, maxBoxHeight);
    if (_mediaHeight == maxBoxHeight) _mediaIsConstrained = true;
    _mediaWidth = screenWidth;

    if (widget.story.media != null) {
      _retrieveStoryMediaInProgress = false;
      return;
    }

    _retrievePostMedia();
  }

  void _retrievePostMedia() async {
    _setRetrieveStoryMediaInProgress(true);
    try {
      _retrievePostMediaOperation = CancelableOperation.fromFuture(
          _userService.getMediaForPost(post: widget.story), onCancel: _onRetrieveStoryMediaOperationCancelled);
      PostMediaList mediaList = await _retrievePostMediaOperation.value;
      widget.story.setMedia(mediaList);
    } catch (error) {
      _onError(error);
    } finally {
      _setRetrieveStoryMediaInProgress(false);
    }
  }

  void _onRetrieveStoryMediaOperationCancelled() {
    debugPrint('Cancelled retrieveStoryMediaOperation');
    _setRetrieveStoryMediaInProgress(false);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _setErrorMessage(error.toHumanReadableMessage());
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _setErrorMessage(errorMessage);
    } else {
      _setErrorMessage(_localizationService.error__unknown_error);
      throw error;
    }
  }

  void _setErrorMessage(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
  }

  void _setRetrieveStoryMediaInProgress(bool retrieveStoryMediaInProgress) {
    if (!mounted) return;
    setState(() {
      _retrieveStoryMediaInProgress = retrieveStoryMediaInProgress;
    });
  }
}
