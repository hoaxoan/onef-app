import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post_image.dart';
import 'package:onef/models/story_image.dart';
import 'dart:math';

import 'package:onef/provider.dart';
import 'package:onef/widgets/icon.dart';

class OFStoryBodyImage extends StatelessWidget {
  final StoryImage storyImage;
  final bool hasExpandButton;
  final double height;
  final double width;

  const OFStoryBodyImage(
      {Key key,
      this.storyImage,
      this.hasExpandButton = false,
      this.height,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = storyImage.image;

    List<Widget> stackItems = [
      _buildImageWidget(imageUrl: imageUrl, width: width, height: height)
    ];

    if (hasExpandButton) {
      stackItems.add(_buildExpandIcon());
    }

    return GestureDetector(
      child: Stack(
        children: stackItems,
      ),
      onTap: () {
        var dialogService = OneFProvider.of(context).dialogService;
       /* dialogService.showZoomablePhotoBoxView(
            imageUrl: imageUrl, context: context);*/
      },
    );
  }

  Widget _buildImageWidget({String imageUrl, double height, double width}) {
    return Image(
      height: height,
      width: width,
      fit: BoxFit.cover,
      image: AdvancedNetworkImage(imageUrl,
          useDiskCache: true,
          fallbackAssetImage: 'assets/images/fallbacks/post-fallback.png',
          retryLimit: 3,
          timeoutDuration: const Duration(minutes: 1)),
    );
  }

  Widget _buildExpandIcon() {
    return Positioned(
        bottom: 15,
        right: 15,
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              //Same dark grey as in OBZoomablePhotoModal
              color: Colors.black87,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: OFIcon(
              OFIcons.expand,
              customSize: 12,
            )));
  }
}
