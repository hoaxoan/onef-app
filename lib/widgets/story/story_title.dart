import 'package:flutter/material.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStoryTitle extends StatelessWidget {
  const OFStoryTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return OFText(
      title,
      style: Theme.of(context).textTheme.display1.copyWith(
        color: Colors.white.withOpacity(0.8),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
