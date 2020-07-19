import 'package:flutter/material.dart';
import 'package:onef/widgets/alerts/alert.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFButtonAlert extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;
  final OFIconData buttonIcon;
  final String buttonText;
  final String assetImage;

  const OFButtonAlert(
      {@required this.onPressed,
      this.isLoading = false,
      @required this.text,
      this.buttonIcon,
      @required this.buttonText,
      this.assetImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: OFAlert(
          child: Row(children: [
        assetImage != null
            ? Padding(
                padding:
                    EdgeInsets.only(right: 30, left: 10, top: 10, bottom: 10),
                child: Image.asset(
                  assetImage,
                  height: 80,
                ),
              )
            : SizedBox(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: OFText(
                      text,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              OFButton(
                icon: buttonIcon != null
                    ? OFIcon(
                        buttonIcon,
                        size: OFIconSize.small,
                      )
                    : null,
                isLoading: isLoading,
                type: OFButtonType.highlight,
                child: Text(buttonText),
                onPressed: onPressed,
              )
            ],
          ),
        )
      ])),
    );
  }
}
