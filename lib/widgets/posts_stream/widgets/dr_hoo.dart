import 'package:flutter/cupertino.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/posts_stream/posts_stream.dart';
import 'package:onef/widgets/theming/highlighted_box.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostsStreamDrHoo extends StatelessWidget {
  final VoidCallback streamRefresher;
  final OFPostsStreamStatus streamStatus;
  final List<Widget> streamPrependedItems;

  const OFPostsStreamDrHoo({
    Key key,
    @required this.streamRefresher,
    @required this.streamStatus,
    @required this.streamPrependedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String drHooTitle;
    String drHooSubtitle;
    String drHooImage = 'assets/images/stickers/owl-instructor.png';
    bool hasRefreshButton = false;

    var provider = OneFProvider.of(context);
    LocalizationService localizationService = provider.localizationService;

    switch (streamStatus) {
      case OFPostsStreamStatus.refreshing:
        drHooTitle = localizationService.posts_stream__refreshing_drhoo_title;
        drHooSubtitle =
            localizationService.posts_stream__refreshing_drhoo_subtitle;
        break;
      case OFPostsStreamStatus.noMoreToLoad:
        drHooTitle = localizationService.posts_stream__empty_drhoo_title;
        drHooSubtitle = localizationService.posts_stream__empty_drhoo_subtitle;
        break;
      case OFPostsStreamStatus.loadingMoreFailed:
        drHooImage = 'assets/images/stickers/perplexed-owl.png';
        drHooTitle =
            localizationService.post__timeline_posts_failed_drhoo_title;
        drHooSubtitle =
            localizationService.post__timeline_posts_failed_drhoo_subtitle;
        hasRefreshButton = true;
        break;
      case OFPostsStreamStatus.empty:
        drHooImage = 'assets/images/stickers/perplexed-owl.png';
        drHooTitle = localizationService.posts_stream__empty_drhoo_title;
        drHooSubtitle = localizationService.posts_stream__empty_drhoo_subtitle;
        hasRefreshButton = true;
        break;
      default:
        drHooTitle =
            localizationService.post__timeline_posts_default_drhoo_title;
        drHooSubtitle =
            localizationService.post__timeline_posts_default_drhoo_subtitle;
        hasRefreshButton = true;
    }

    List<Widget> drHooColumnItems = [
      Image.asset(
        drHooImage,
        height: 100,
      ),
      const SizedBox(
        height: 20.0,
      ),
      OFText(
        drHooTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 10.0,
      ),
      OFText(
        drHooSubtitle,
        textAlign: TextAlign.center,
      )
    ];

    if (hasRefreshButton) {
      drHooColumnItems.addAll([
        const SizedBox(
          height: 30,
        ),
        OFButton(
          icon: const OFIcon(
            OFIcons.refresh,
            size: OFIconSize.small,
          ),
          type: OFButtonType.highlight,
          child: OFText(localizationService.post__timeline_posts_refresh_posts),
          onPressed: streamRefresher,
          isLoading: streamStatus == OFPostsStreamStatus.refreshing,
        )
      ]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical:
              streamPrependedItems != null && streamPrependedItems.isNotEmpty ||
                      streamStatus == OFPostsStreamStatus.empty ||
                      streamStatus == OFPostsStreamStatus.refreshing ||
                      streamStatus == OFPostsStreamStatus.loadingMoreFailed
                  ? 20
                  : 0),
      child: OFHighlightedBox(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: drHooColumnItems,
            ),
          ),
        ),
      ),
    );
  }
}
