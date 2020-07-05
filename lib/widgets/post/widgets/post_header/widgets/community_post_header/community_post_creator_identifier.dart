import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/theming/secondary_text.dart';

class OFCommunityPostCreatorIdentifier extends StatelessWidget {
  final Post post;
  final VoidCallback onUsernamePressed;

  static int postCommentMaxVisibleLength = 500;

  OFCommunityPostCreatorIdentifier({
    Key key,
    @required this.onUsernamePressed,
    @required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParserService = provider.themeValueParserService;
    var utilsService = provider.utilsService;
    var localizationService = provider.localizationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          OFTheme theme = snapshot.data;

          Color secondaryTextColor =
              themeValueParserService.parseColor(theme.secondaryTextColor);

          String commenterUsername = post.creator.username;
          String commenterName = post.creator.getProfileName();
          String created = utilsService.timeAgo(post.created, localizationService);

          return GestureDetector(
            onTap: onUsernamePressed,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(
                            color: secondaryTextColor, fontSize: 12),
                        children: [
                          TextSpan(
                              text: '$commenterName',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' @$commenterUsername',
                              style: TextStyle(
                                  fontSize: 12)),
                        ]),
                  )
                ),
                OFSecondaryText(
                  ' · $created',
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          );
        });
  }
}
