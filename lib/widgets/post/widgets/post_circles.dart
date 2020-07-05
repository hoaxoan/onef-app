import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/models/post.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/circle_color_preview.dart';
import 'package:onef/widgets/cirles_wrap.dart';
import 'package:onef/widgets/theming/actionable_smart_text.dart';
import 'package:onef/widgets/theming/text.dart';


class OFPostCircles extends StatelessWidget {
  final Post _post;

  OFPostCircles(this._post);

  @override
  Widget build(BuildContext context) {
    LocalizationService _localizationService = OneFProvider.of(context).localizationService;
    if (_post.hasCircles()) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 26.0,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            physics: const ClampingScrollPhysics(),
            itemCount: 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return OFCirclesWrap(
                  textSize: OFTextSize.small,
                  circlePreviewSize: OFCircleColorPreviewSize.extraSmall,
                  leading: OFText(_localizationService.trans('post__you_shared_with'), size: OFTextSize.small),
                  circles: _post.getPostCircles()
              );
            },
          ),
        ),
      );
    } else if (_post.isEncircled != null && _post.isEncircled) {
      String postCreatorUsername = _post.creator.username;

      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          children: <Widget>[
            OFText(
              _localizationService.trans('post__shared_privately_on'),
              size: OFTextSize.small,
            ),
            SizedBox(
              width: 10,
            ),
            OFCircleColorPreview(
              Circle(color: '#ffffff'),
              size: OFCircleColorPreviewSize.extraSmall,
            ),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: OFActionableSmartText(
                text: _localizationService.post__usernames_circles(postCreatorUsername),
                size: OFTextSize.small,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
