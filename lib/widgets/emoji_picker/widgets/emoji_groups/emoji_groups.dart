import 'package:flutter/material.dart';
import 'package:onef/models/emoji_group.dart';
import 'package:onef/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/emoji_group.dart';
import 'package:onef/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';

class OFEmojiGroups extends StatelessWidget {
  final OnEmojiPressed onEmojiPressed;
  final List<EmojiGroup> emojiGroups;

  OFEmojiGroups(this.emojiGroups, {this.onEmojiPressed});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: emojiGroups.length,
        itemBuilder: (BuildContext context, index) {
          EmojiGroup emojiGroup = emojiGroups[index];
          return OFEmojiGroup(
            emojiGroup,
            onEmojiPressed: onEmojiPressed,
          );
        });
  }
}
