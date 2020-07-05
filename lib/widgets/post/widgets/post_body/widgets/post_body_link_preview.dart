import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_preview_link_data.dart';
import 'package:onef/provider.dart';

class OFPostBodyLinkPreview extends StatelessWidget {
  final Post post;

  const OFPostBodyLinkPreview({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: StreamBuilder<Post>(
          stream: post.updateSubject,
          initialData: post,
          builder: _buildLinkPreview),
    );
  }

  Widget _buildLinkPreview(BuildContext context, AsyncSnapshot<Post> snapshot) {
    var provider = OneFProvider.of(context);
    String newLink = provider.linkPreviewService.checkForLinkPreviewUrl(post.text);

    if (post.linkPreview != null && newLink == post.linkPreview.url) {
      return OFLinkPreview(
        linkPreview: post.linkPreview,
      );
    }

    return OFLinkPreview(
        link: newLink, onLinkPreviewRetrieved: _onLinkPreviewRetrieved);
  }

  void _onLinkPreviewRetrieved(LinkPreview linkPreview) {
    post.setLinkPreview(linkPreview);
  }
}
