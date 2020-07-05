import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:onef/models/emoji.dart';
import 'package:onef/models/emoji_group.dart';

enum OFEmojiSize { small, medium, large }

class OFEmoji extends StatelessWidget {
  final Emoji emoji;
  final EmojiGroup emojiGroup;
  final OnEmojiPressed onEmojiPressed;
  final OFEmojiSize size;

  OFEmoji(this.emoji,
      {this.onEmojiPressed, this.emojiGroup, this.size = OFEmojiSize.medium});

  @override
  Widget build(BuildContext context) {
    double dimensions = getIconDimensions(size);

    return IconButton(
        icon: Image(
          height: dimensions,
          image: AdvancedNetworkImage(emoji.image, useDiskCache: true),
        ),
        onPressed: onEmojiPressed != null
            ? () {
                onEmojiPressed(emoji, emojiGroup);
              }
            : null);
  }

  double getIconDimensions(OFEmojiSize size) {
    double iconSize;

    switch (size) {
      case OFEmojiSize.large:
        iconSize = 45;
        break;
      case OFEmojiSize.medium:
        iconSize = 25;
        break;
      case OFEmojiSize.small:
        iconSize = 15;
        break;
      default:
    }

    return iconSize;
  }
}

typedef void OnEmojiPressed(Emoji pressedEmoji, EmojiGroup emojiGroup);
