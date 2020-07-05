import 'package:flutter/cupertino.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/avatars/avatar.dart';

class OFOwnProfileActiveIcon extends StatelessWidget {
  final String avatarUrl;
  final OFAvatarSize size;

  const OFOwnProfileActiveIcon({Key key, this.avatarUrl, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeService = OneFProvider.of(context).themeService;
    var themeValueParserService =
        OneFProvider.of(context).themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                border: Border.all(
                    color: themeValueParserService
                        .parseGradient(theme.primaryAccentColor)
                        .colors[1])),
            padding: EdgeInsets.all(2.0),
            child: OFAvatar(
              avatarUrl: avatarUrl,
              size: size,
            ),
          );
        });
  }
}
