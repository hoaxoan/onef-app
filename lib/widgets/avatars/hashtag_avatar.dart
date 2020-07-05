import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/avatars/letter_avatar.dart';

class OFHashtagAvatar extends StatelessWidget {
  final Hashtag hashtag;
  final OFAvatarSize size;
  final VoidCallback onPressed;
  final bool isZoomable;
  final double borderRadius;
  final double customSize;

  const OFHashtagAvatar(
      {Key key,
      @required this.hashtag,
      this.size = OFAvatarSize.small,
      this.isZoomable = false,
      this.borderRadius,
      this.onPressed,
      this.customSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: hashtag.updateSubject,
        initialData: hashtag,
        builder: (BuildContext context, AsyncSnapshot<Hashtag> snapshot) {
          Hashtag hashtag = snapshot.data;
          bool hashtagHasImage = hashtag.hasImage();

          Widget avatar;

          if (hashtagHasImage) {
            avatar = OFAvatar(
                avatarUrl: hashtag?.image,
                size: size,
                onPressed: onPressed,
                isZoomable: isZoomable,
                borderRadius: borderRadius,
                customSize: customSize);
          } else {
            String hashtagHexColor = hashtag.color;

            var providerState = OneFProvider.of(context);

            Color hashtagColor =
                providerState.utilsService.parseHexColor(hashtagHexColor);
            Color textColor = Colors.white;

            avatar = OFLetterAvatar(
                letter: '#',
                color: hashtagColor,
                size: size,
                onPressed: onPressed,
                borderRadius: borderRadius,
                labelColor: textColor,
                customSize: customSize);
          }

          return avatar;
        });
  }
}
