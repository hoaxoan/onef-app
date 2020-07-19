import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onef/models/community.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/tiles/community_tile.dart';

class OFPostCommunityPreviewer extends StatelessWidget {
  final Community community;

  const OFPostCommunityPreviewer({Key key, @required this.community})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalizationService localizationService = OneFProvider.of(context).localizationService;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OFSecondaryText(localizationService.post__sharing_post_to),
        const SizedBox(
          height: 10,
        ),
        OFCommunityTile(
          community,
          size: OFCommunityTileSize.small,
        )
      ],
    );
  }
}
