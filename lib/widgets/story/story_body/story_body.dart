import 'package:flutter/material.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';
import 'file:///G:/reaction/onef/lib/widgets/story/story_body/story_body_text.dart';

class OFStoryBody extends StatelessWidget {
  final Story story;
  final OnTextExpandedChange onTextExpandedChange;
  final String inViewId;

  const OFStoryBody(this.story,
      {Key key, this.onTextExpandedChange, this.inViewId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyItems = [];
    var provider = OneFProvider.of(context);

    if (story.hasTitle()) {
      bodyItems.add(OFStoryBodyText(
        story,
        onTextExpandedChange: onTextExpandedChange,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bodyItems,
            ))
      ],
    );
  }
}
