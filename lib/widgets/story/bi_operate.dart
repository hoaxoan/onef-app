import 'package:flutter/material.dart';
import 'package:onef/widgets/shadowed_box.dart';
import 'package:onef/widgets/theming/text.dart';

const kYes = 'YES!';
const kNoThanks = 'NO THANKS';

class OFBiOperate extends StatelessWidget {
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;
  final String positiveLabel;
  final String negativeLabel;
  final Color color;

  const OFBiOperate(
      {Key key,
        @required this.onPositivePressed,
        @required this.onNegativePressed,
        this.positiveLabel = kYes,
        this.negativeLabel = kNoThanks,
        this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FractionallySizedBox(
          widthFactor: 0.75,
          child: OFShadowedBox(
            borderRadius: BorderRadius.circular(45.0),
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              shape: StadiumBorder(),
              color: Colors.white,
              onPressed: onPositivePressed,
              child: OFText(
                positiveLabel,
                style: theme.textTheme.subhead.copyWith(
                  color: color != null ? color : theme.primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.0, height: 16.0),
        FlatButton(
          shape: StadiumBorder(),
          onPressed: onNegativePressed,
          color: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: OFText(
            negativeLabel,
            style: theme.textTheme.subhead.copyWith(
              color: Colors.white30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
