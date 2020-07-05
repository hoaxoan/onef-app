import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFPostIsClosed extends StatelessWidget {
  final Post _post;

  OFPostIsClosed(this._post);

  @override
  Widget build(BuildContext context) {
    bool isClosed = _post.isClosed ?? false;
    LocalizationService localizationService = OneFProvider.of(context).localizationService;

    if (isClosed) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: <Widget>[
            const OFIcon(OFIcons.closePost, size: OFIconSize.small,),
            const SizedBox(width: 10,),
            OFText(localizationService.post__is_closed, size: OFTextSize.small)
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
