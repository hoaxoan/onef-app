import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/media.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/theming/highlighted_box.dart';
import 'package:onef/widgets/theming/text.dart';
import 'dart:convert';

import 'icon.dart';
import 'linear_progress_indicator.dart';

class OFNewPostDataUploader extends StatefulWidget {
  final OFNewPostData data;
  final Function(Post, OFNewPostData) onPostPublished;
  final ValueChanged<OFNewPostData> onCancelled;

  const OFNewPostDataUploader(
      {Key key,
      @required this.data,
      @required this.onPostPublished,
      @required this.onCancelled})
      : super(key: key);

  @override
  OFNewPostDataUploaderState createState() {
    return OFNewPostDataUploaderState();
  }
}

class OFNewPostDataUploaderState extends State<OFNewPostDataUploader>
    with AutomaticKeepAliveClientMixin {
  UserService _userService;
  LocalizationService _localizationService;
  MediaService _mediaPickerService;

  bool _needsBootstrap;
  OFPostUploaderStatus _status;

  String _statusMessage = '';

  static double mediaPreviewSize = 40;

  Timer _checkPostStatusTimer;

  CancelableOperation _getPostStatusOperation;
  CancelableOperation _uploadPostOperation;
  OFNewPostData _data;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _data = widget.data;
    _status = OFPostUploaderStatus.idle;
  }

  @override
  void dispose() {
    super.dispose();
    _ensurePostStatusTimerIsCancelled();
    _getPostStatusOperation?.cancel();
    _uploadPostOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _localizationService = provider.localizationService;
      _mediaPickerService = provider.mediaService;
      _bootstrap();
      _needsBootstrap = false;
    }

    List<Widget> rowItems = [];

    if (_data.hasMedia()) {
      rowItems.addAll([
        _buildMediaPreview(),
        const SizedBox(
          width: 15,
        ),
      ]);
    }

    rowItems.addAll([_buildStatusText(), _buildActionButtons()]);

    return OFHighlightedBox(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(children: rowItems),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: -3,
            left: 0,
            right: 0,
            child: _status == OFPostUploaderStatus.creatingPost ||
                    _status == OFPostUploaderStatus.compressingPostMedia ||
                    _status == OFPostUploaderStatus.addingPostMedia ||
                    _status == OFPostUploaderStatus.processing
                ? _buildProgressBar()
                : const SizedBox(),
          )
        ],
      ),
    );
  }

  void _bootstrap() {
    _startUpload();
  }

  void _startUpload() {
    _uploadPostOperation = CancelableOperation.fromFuture(_uploadPost());
  }

  Future _uploadPost() async {
    try {
      if (_data.createdDraftPost == null) {
        _setStatus(OFPostUploaderStatus.creatingPost);
        _setStatusMessage(_localizationService.post_uploader__creating_post);
        _data.createdDraftPost = await _createPost();
      }

      if (_data.remainingMediaToCompress.isNotEmpty) {
        _setStatusMessage(
            _localizationService.post_uploader__compressing_media);
        _setStatus(OFPostUploaderStatus.compressingPostMedia);
        await _compressPostMedia();
      }

      if (_data.remainingCompressedMediaToUpload.isNotEmpty) {
        _setStatusMessage(_localizationService.post_uploader__uploading_media);
        _setStatus(OFPostUploaderStatus.addingPostMedia);
        await _addPostMedia();
      }

      if (!_data.postPublishRequested) {
        _setStatusMessage(_localizationService.post_uploader__publishing);
        _setStatus(OFPostUploaderStatus.publishing);
        await _publishPost();
        _data.postPublishRequested = true;
      }

      _setStatusMessage(_localizationService.post_uploader__processing);
      _setStatus(OFPostUploaderStatus.processing);
      _ensurePostStatusTimerIsCancelled();

      if (_data.createdDraftPostStatus == null ||
          _data.createdDraftPostStatus != OBPostStatus.published) {
        _checkPostStatusTimer =
            Timer.periodic(new Duration(seconds: 1), (timer) async {
          if (_getPostStatusOperation != null) return;
          _getPostStatusOperation = CancelableOperation.fromFuture(
              _userService.getPostStatus(post: _data.createdDraftPost));
          OBPostStatus status = await _getPostStatusOperation.value;
          debugLog(
              'Polling for post published status, got status: ${status.toString()}');
          _data.createdDraftPostStatus = status;
          if (_data.createdDraftPostStatus == OBPostStatus.published) {
            debugLog('Received post status is published');
            _checkPostStatusTimer.cancel();
            _getPublishedPost();
          }
          _getPostStatusOperation = null;
        });
      } else {
        _getPublishedPost();
      }
    } catch (error) {
      if (error is HttpieConnectionRefusedError) {
        _setStatusMessage(error.toHumanReadableMessage());
      } else if (error is HttpieRequestError) {
        String errorMessage = await error.toHumanReadableMessage();
        _setStatusMessage(errorMessage);
      } else {
        _setStatusMessage(
            _localizationService.post_uploader__generic_upload_failed);
        // only throw error if its not one of the above handled errors
        throw error;
      }
      _setStatus(OFPostUploaderStatus.failed);
    }
  }

  Future _createPost() async {
    Post draftPost;

    if (_data.community != null) {
      debugLog('Creating community post');

      draftPost = await _userService.createPostForCommunity(_data.community,
          text: _data.text, isDraft: true);
    } else {
      debugLog('Creating circles post');

      draftPost = await _userService.createPost(
          text: _data.text, circles: _data.getCircles(), isDraft: true);
    }

    debugLog('Post created successfully');

    return draftPost;
  }

  Future _getPublishedPost() async {
    debugLog('Retrieving the published post');

    Post publishedPost =
        await _userService.getPostWithUuid(_data.createdDraftPost.uuid);
    widget.onPostPublished(publishedPost, widget.data);
    _removeMediaFromCache();
  }

  Future _compressPostMedia() {
    debugLog('Compressing post media');

    return Future.wait(
        _data.remainingMediaToCompress.map(_compressPostMediaItem).toList());
  }

  Future _compressPostMediaItem(File postMediaItem) async {
    String mediaMime = lookupMimeType(postMediaItem.path);
    String mediaMimeType = mediaMime.split('/')[0];

    if (mediaMimeType == 'image') {
      File compressedImage =
          await _mediaPickerService.compressImage(postMediaItem);
      _data.remainingCompressedMediaToUpload.add(compressedImage);
      if (compressedImage.path.indexOf('compressed') > -1) {
        _data.compressedMedia.add(compressedImage);
      }
      debugLog(
          'Compressed image from ${postMediaItem.lengthSync()} to ${compressedImage.lengthSync()}');
    } else if (mediaMimeType == 'video') {
      File compressedVideo =
          await _mediaPickerService.compressVideo(postMediaItem);
      if (compressedVideo.path.indexOf('compressed') > -1) {
        _data.compressedMedia.add(compressedVideo);
      }
      _data.remainingCompressedMediaToUpload.add(compressedVideo);
      debugLog(
          'Compressed video from ${postMediaItem.lengthSync()} to ${compressedVideo.lengthSync()}');
    } else {
      debugLog('Unsupported media type for compression');
    }
    _data.remainingMediaToCompress.remove(postMediaItem);
  }

  Future _addPostMedia() {
    debugLog('Adding post media');

    return Future.wait(_data.remainingCompressedMediaToUpload
        .map(_uploadPostMediaItem)
        .toList());
  }

  Future _uploadPostMediaItem(File file) async {
    await _userService.addMediaToPost(file: file, post: _data.createdDraftPost);
    _data.remainingCompressedMediaToUpload.remove(file);
  }

  Widget _buildProgressBar() {
    return OFLinearProgressIndicator();
  }

  Widget _buildMediaPreview() {
    return FutureBuilder(
      future: _getMediaThumbnail(),
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        File mediaThumbnail = snapshot.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image(
            image: FileImage(mediaThumbnail),
            height: mediaPreviewSize,
            width: mediaPreviewSize,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Future<File> _getMediaThumbnail() async {
    if (_data.mediaThumbnail != null) return _data.mediaThumbnail;

    File mediaToPreview = _data.media.first;
    File mediaThumbnail;

    String mediaMime = lookupMimeType(mediaToPreview.path);
    String mediaMimeType = mediaMime.split('/')[0];

    if (mediaMimeType == 'image') {
      mediaThumbnail = mediaToPreview;
    } else if (mediaMimeType == 'video') {
      mediaThumbnail =
          await _mediaPickerService.getVideoThumbnail(mediaToPreview);
    } else {
      debugLog('Unsupported media type for preview thumbnail');
    }

    _data.mediaThumbnail = mediaThumbnail;

    return mediaThumbnail;
  }

  Widget _buildStatusText() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OFText(
              _statusMessage,
              textAlign: TextAlign.left,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    List<Widget> activeActions = [];

    switch (_status) {
      case OFPostUploaderStatus.creatingPost:
      case OFPostUploaderStatus.addingPostMedia:
        activeActions.add(_buildCancelButton());
        break;
      case OFPostUploaderStatus.failed:
        activeActions.add(_buildCancelButton());
        activeActions.add(_buildRetryButton());
        break;
      default:
    }

    return Row(
      children: activeActions,
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _onWantsToCancel,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OFIcon(OFIcons.cancel),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _onWantsToRetry,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OFIcon(OFIcons.retry),
      ),
    );
  }

  void _onWantsToRetry() async {
    if (_status == OFPostUploaderStatus.creatingPost ||
        _status == OFPostUploaderStatus.addingPostMedia) return;

    debugLog('Retrying');
    _startUpload();
  }

  void _onWantsToCancel() async {
    if (_status == OFPostUploaderStatus.cancelling) return;
    _setStatus(OFPostUploaderStatus.cancelling);

    debugLog('Cancelling');

    // Delete post
    if (_data.createdDraftPost != null) {
      debugLog('Deleting post');
      try {
        await _userService.deletePost(_data.createdDraftPost);
        debugLog('Successfully deleted post');
      } catch (error) {
        // If it doesnt work, will get cleaned up by a scheduled job
        debugLog('Failed to delete post wit error: ${error.toString()}');
      }
    }

    _setStatus(OFPostUploaderStatus.cancelled);
    widget.onCancelled(widget.data);
    _removeMediaFromCache();
  }

  void _removeMediaFromCache() async {
    debugLog('Clearing local cached media for post');
    _data.media?.forEach((File mediaObject) {
      if (mediaObject.existsSync()) mediaObject.delete();
    });
    _data.compressedMedia?.forEach((File mediaObject) => mediaObject.delete());
    if (_data.mediaThumbnail != _data.media.first) {
      _data.mediaThumbnail?.delete();
    }
  }

  Future _publishPost() async {
    debugLog('Publishing post');
    return _userService.publishPost(post: _data.createdDraftPost);
  }

  void _setStatus(OFPostUploaderStatus status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  void _setStatusMessage(String statusMessage) {
    if (mounted) {
      setState(() {
        _statusMessage = statusMessage;
      });
    }
  }

  void _ensurePostStatusTimerIsCancelled() {
    if (_checkPostStatusTimer != null && _checkPostStatusTimer.isActive)
      _checkPostStatusTimer.cancel();
  }

  void debugLog(String log) {
    debugPrint('OBNewPostDataUploader:$log');
  }

  @override
  bool get wantKeepAlive => true;
}

class OFNewPostData {
  String text;
  List<File> media;
  Community community;
  List<Circle> circles;

  // State persistence variables
  Post createdDraftPost;
  OBPostStatus createdDraftPostStatus;
  List<File> remainingMediaToCompress;
  List<File> compressedMedia = [];
  List<File> remainingCompressedMediaToUpload = [];
  bool postPublishRequested = false;
  File mediaThumbnail;

  String _cachedKey;

  OFNewPostData({this.text, this.media, this.community, this.circles}) {
    remainingMediaToCompress = media.toList();
  }

  bool hasMedia() {
    return media != null && media.isNotEmpty;
  }

  List<File> getMedia() {
    return hasMedia() ? media.toList() : [];
  }

  void setCircles(List<Circle> circles) {
    this.circles = circles;
  }

  void setCommunity(Community community) {
    this.community = community;
  }

  List<Circle> getCircles() {
    return circles.toList();
  }

  String getUniqueKey() {
    if (_cachedKey != null) return _cachedKey;

    String key = '';
    if (text != null) key += text;
    if (hasMedia()) {
      media.forEach((File mediaItem) {
        key += mediaItem.path;
      });
    }

    var bytes = utf8.encode(key);
    var digest = sha256.convert(bytes);

    _cachedKey = digest.toString();

    return _cachedKey;
  }
}

enum OFPostUploaderStatus {
  idle,
  creatingPost,
  compressingPostMedia,
  addingPostMedia,
  publishing,
  processing,
  success,
  failed,
  cancelling,
  cancelled,
}
