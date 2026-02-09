import 'package:flutter/material.dart';
import '../constants/emoji_sizes.dart';
import '../screens/chat_room_screen.dart';

class EmojiRenderer {
  static Widget render(String code, double size, {String? semanticLabel}) {
    // Получаем доступ к _emojiAssets из ChatRoomScreen
    final emojiAssets = {
      ':smile:': 'assets/emojis/smiley.gif',
      ':smiley:': 'assets/emojis/smiley.gif',
      ':cool:': 'assets/emojis/cool.gif',
      ':shock:': 'assets/emojis/shocked.gif',
      ':tongue:': 'assets/emojis/tongue.gif',
      ':heart:': 'assets/emojis/kiss.gif',
      ':sad:': 'assets/emojis/sad.gif',
      ':angry:': 'assets/emojis/angry.gif',
      ':grin:': 'assets/emojis/grin.gif',
      ':wink:': 'assets/emojis/wink.gif',
      ':cry:': 'assets/emojis/cry.gif',
      ':laugh:': 'assets/emojis/laugh.gif',
      ':evil:': 'assets/emojis/evil.gif',
      ':afro:': 'assets/emojis/afro.gif',
      ':angel:': 'assets/emojis/angel.gif',
      ':azn:': 'assets/emojis/azn.gif',
      ':bang:': 'assets/emojis/bang.gif',
      ':blank:': 'assets/emojis/blank.gif',
      ':buenpost:': 'assets/emojis/buenpost.gif',
      ':cheesy:': 'assets/emojis/cheesy.gif',
      ':embarrassed:': 'assets/emojis/embarrassed.gif',
      ':huh:': 'assets/emojis/huh.gif',
      ':lipsrsealed:': 'assets/emojis/lipsrsealed.gif',
      ':mario:': 'assets/emojis/mario.gif',
      ':pacman:': 'assets/emojis/pacman.gif',
      ':police:': 'assets/emojis/police.gif',
      ':rolleyes:': 'assets/emojis/rolleyes.gif',
      ':sad2:': 'assets/emojis/sad2.gif',
      ':shrug:': 'assets/emojis/shrug.gif',
      ':undecided:': 'assets/emojis/undecided.gif',
    };

    if (!emojiAssets.containsKey(code)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.broken_image,
          size: size * 0.6,
          color: Colors.red,
        ),
      );
    }

    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        emojiAssets[code]!,
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
        semanticLabel: semanticLabel ?? 'Emoji $code',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.broken_image,
              size: size * 0.6,
              color: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
