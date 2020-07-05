import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStreamLoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const OFStreamLoadMoreButton({Key key, this.onPressed, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);

    String buttonText = text ?? provider.localizationService.post__load_more;

    return OFButton(
        type: OFButtonType.highlight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OFIcon(
              OFIcons.loadMore,
              customSize: 20.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            OFText(buttonText),
          ],
        ),
        onPressed: onPressed);
  }
}
