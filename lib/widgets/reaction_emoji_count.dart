import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:onef/models/reactions_emoji_count.dart';
import 'package:onef/widgets/theming/text.dart';

import 'buttons/button.dart';

class OFEmojiReactionButton extends StatelessWidget {
  final ReactionsEmojiCount postReactionsEmojiCount;
  final bool reacted;
  final ValueChanged<ReactionsEmojiCount> onPressed;
  final ValueChanged<ReactionsEmojiCount> onLongPressed;
  final OBEmojiReactionButtonSize size;

  const OFEmojiReactionButton(this.postReactionsEmojiCount,
      {this.onPressed,
      this.reacted,
      this.onLongPressed,
      this.size = OBEmojiReactionButtonSize.medium});

  @override
  Widget build(BuildContext context) {
    var emoji = postReactionsEmojiCount.emoji;

    List<Widget> buttonRowItems = [
      Image(
        height: size == OBEmojiReactionButtonSize.medium ? 18 : 14,
        image: AdvancedNetworkImage(emoji.image, useDiskCache: true),
      ),
      const SizedBox(
        width: 10.0,
      ),
      OFText(
        postReactionsEmojiCount.getPrettyCount(),
        style: TextStyle(
            fontWeight: reacted ? FontWeight.bold : FontWeight.normal,
            fontSize: size == OBEmojiReactionButtonSize.medium ? null : 12),
      )
    ];

    Widget buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center, children: buttonRowItems);

    return OFButton(
      minWidth: 50,
      child: buttonChild,
      onLongPressed: () {
        if (onLongPressed != null) onLongPressed(postReactionsEmojiCount);
      },
      onPressed: () {
        if (onPressed != null) onPressed(postReactionsEmojiCount);
      },
      type: OFButtonType.highlight,
    );
  }
}

enum OBEmojiReactionButtonSize { small, medium }
