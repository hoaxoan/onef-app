import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';
import 'package:onef/widgets/tiles/loading_tile.dart';

class OFReportPostTile extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onPostReported;
  final VoidCallback onWantsToReportPost;

  const OFReportPostTile({
    Key key,
    this.onPostReported,
    @required this.post,
    this.onWantsToReportPost,
  }) : super(key: key);

  @override
  OFReportPostTileState createState() {
    return OFReportPostTileState();
  }
}

class OFReportPostTileState extends State<OFReportPostTile> {
  NavigationService _navigationService;
  LocalizationService _localizationService;
  bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    _navigationService = provider.navigationService;
    _localizationService = provider.localizationService;

    return StreamBuilder(
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool isReported = post.isReported ?? false;

        return OFLoadingTile(
          isLoading: _requestInProgress || isReported,
          leading: OFIcon(OFIcons.report),
          title: OFText(
              isReported ? _localizationService.moderation__you_have_reported_post_text : _localizationService.moderation__report_post_text),
          onTap: isReported ? () {} : _reportPost,
        );
      },
    );
  }

  void _reportPost() {
    if (widget.onWantsToReportPost != null) widget.onWantsToReportPost();
    _navigationService.navigateToReportObject(
        context: context,
        object: widget.post,
        onObjectReported: (dynamic reportedObject) {
          if (reportedObject != null && widget.onPostReported != null)
            widget.onPostReported(reportedObject as Post);
        });
  }
}
