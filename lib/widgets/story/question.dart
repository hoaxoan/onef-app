import 'package:flutter/material.dart';
import 'package:onef/widgets/theming/text.dart';

class OFQuestion extends StatelessWidget {
  final String question;

  const OFQuestion(this.question, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left:  16.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: OFText(
            question,
            style: Theme.of(context)
                .textTheme
                .headline
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
