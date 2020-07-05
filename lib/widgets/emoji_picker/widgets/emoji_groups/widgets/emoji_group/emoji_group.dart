import 'package:flutter/material.dart';
import 'package:onef/models/emoji.dart';
import 'package:onef/models/emoji_group.dart';
import 'package:onef/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:onef/widgets/theming/text.dart';

class OFEmojiGroup extends StatelessWidget {
  final EmojiGroup emojiGroup;
  final OnEmojiPressed onEmojiPressed;

  OFEmojiGroup(this.emojiGroup, {this.onEmojiPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OFText(emojiGroup.keyword,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          const SizedBox(
            height: 10.0,
          ),
          Wrap(
            spacing: 20.0,
            children: this.emojiGroup.emojis.emojis.map((Emoji emoji) {
              return OFEmoji(
                emoji,
                emojiGroup: emojiGroup,
                onEmojiPressed: onEmojiPressed,
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
