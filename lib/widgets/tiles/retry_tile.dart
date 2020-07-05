import 'package:flutter/material.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFRetryTile extends StatelessWidget {
  final String text;
  final VoidCallback onWantsToRetry;

  const OFRetryTile(
      {Key key, this.text = 'Tap to retry.', @required this.onWantsToRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onWantsToRetry,
      child: ListTile(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OFIcon(OFIcons.refresh),
            const SizedBox(
              width: 10.0,
            ),
            OFText(text)
          ],
        ),
      ),
    );
  }
}
