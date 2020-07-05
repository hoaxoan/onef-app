import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';

class OFStoryBodyLinkPreview extends StatelessWidget {
  final Story story;

  const OFStoryBodyLinkPreview({Key key, this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: StreamBuilder<Story>(
          stream: story.updateSubject,
          initialData: story,
          builder: _buildLinkPreview),
    );
  }

  Widget _buildLinkPreview(BuildContext context, AsyncSnapshot<Story> snapshot) {
    var provider = OneFProvider.of(context);
   /* String newLink = provider.linkPreviewService.checkForLinkPreviewUrl(story.title);

    if (story.linkPreview != null && newLink == story.linkPreview.url) {
      return OFLinkPreview(
        linkPreview: story.linkPreview,
      );
    }

    return OFLinkPreview(
        link: newLink, onLinkPreviewRetrieved: _onLinkPreviewRetrieved);*/

   return null;
  }

  /*void _onLinkPreviewRetrieved(LinkPreview linkPreview) {
    post.setLinkPreview(linkPreview);
  }*/
}
