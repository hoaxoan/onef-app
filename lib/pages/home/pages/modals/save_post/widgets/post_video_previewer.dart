import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:onef/models/post_video.dart';
import 'package:onef/models/video_format.dart';
import 'package:onef/provider.dart';

class OFPostVideoPreview extends StatelessWidget {
  final File postVideoFile;
  final PostVideo postVideo;
  final VoidCallback onRemove;
  final double buttonSize = 30.0;
  final double playIconSize;
  static double avatarBorderRadius = 10.0;

  const OFPostVideoPreview(
      {Key key,
      this.postVideoFile,
      this.postVideo,
      this.onRemove,
      this.playIconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isFileVideo = postVideoFile != null;

    var provider = OneFProvider.of(context);

    Widget videoPreview = isFileVideo
        ? FutureBuilder<File>(
            future: provider.mediaService.getVideoThumbnail(postVideoFile),
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              if (snapshot.data == null) return const SizedBox();

              return _wrapImageWidgetForThumbnail(Image.file(
                snapshot.data,
                fit: BoxFit.cover,
              ));
            })
        : _wrapImageWidgetForThumbnail(Image(
            fit: BoxFit.cover,
            image: AdvancedNetworkImage(postVideo.thumbnail,
                useDiskCache: true,
                fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png',
                retryLimit: 0),
          ));

    return Stack(
      children: <Widget>[
        videoPreview,
        onRemove != null
            ? Positioned(
                top: 10,
                right: 10,
                child: _buildRemoveButton(),
              )
            : const SizedBox(),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: Center(
            child: _buildPlayButton(context),
          ),
        ),
      ],
    );
  }

  Widget _wrapImageWidgetForThumbnail(Widget image) {
    return SizedBox(
      height: 200.0,
      width: 200,
      child: ClipRRect(
          borderRadius: new BorderRadius.circular(avatarBorderRadius),
          child: image),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: onRemove,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          onPressed: onRemove,
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.clear,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _onWantsToPlay(context);
      },
      child: SizedBox(
          width: playIconSize,
          height: playIconSize,
          child: Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 50,
            ),
          )),
    );
  }

  void _onWantsToPlay(BuildContext context) {
    var provider = OneFProvider.of(context);

    String postVideoUrl;

    if (postVideo != null)
      postVideoUrl = postVideo.getVideoFormatOfType(OFVideoFormatType.mp4SD).file;

    provider.dialogService.showVideo(
        context: context,
        video: postVideoFile,
        autoPlay: true,
        videoUrl: postVideoUrl);
  }
}
