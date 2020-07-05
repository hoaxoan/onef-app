import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/post/widgets/post_body/widgets/post_body_link_preview.dart';
import 'package:onef/widgets/post/widgets/post_body/widgets/post_body_media/post_body_media.dart';
import 'package:onef/widgets/post/widgets/post_body/widgets/post_body_text.dart';

class OFPostBody extends StatelessWidget {
  final Post post;
  final OnTextExpandedChange onTextExpandedChange;
  final String inViewId;

  const OFPostBody(this.post,
      {Key key, this.onTextExpandedChange, this.inViewId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyItems = [];
    var provider = OneFProvider.of(context);
    if (post.hasMediaThumbnail()) {
      bodyItems.add(OFPostBodyMedia(post: post, inViewId: inViewId));
    }

    if (post.hasText()) {
      if (!post.hasMediaThumbnail() &&
          provider.linkPreviewService.hasLinkPreviewUrl(post.text)) {
        bodyItems.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: OFPostBodyLinkPreview(post: post),
          ),
        );
      }

      bodyItems.add(OFPostBodyText(
        post,
        onTextExpandedChange: onTextExpandedChange,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bodyItems,
        ))
      ],
    );
  }
}
