import 'package:flutter/material.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStoryDate extends StatelessWidget {
  const OFStoryDate({
    Key key,
    @required this.storyDate,
  }) : super(key: key);

  final DateTime storyDate;

  @override
  Widget build(BuildContext context) {
    return OFText(
      storyDate.toString(),
      style: Theme.of(context).textTheme.title.copyWith(
          color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
    );
  }
}
