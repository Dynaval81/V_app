import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom TextEditingController that renders emoji codes as images inline
/// Shows :smile: as actual GIF while keeping text format for sending
class EmojiTextEditingController extends TextEditingController {
  late Map<String, String> _emojiAssets;
  bool isDark;

  EmojiTextEditingController({
    required Map<String, String> emojiAssets,
    required this.isDark,
    String? text,
  }) : super(text: text ?? '') {
    _emojiAssets = emojiAssets;
  }

  Map<String, String> get emojiAssets => _emojiAssets;
  
  set emojiAssets(Map<String, String> assets) {
    _emojiAssets = assets;
    notifyListeners();
  }

  void updateTheme(bool isDark) {
    this.isDark = isDark;
  }

  // Helper to render emoji asset as GIF or SVG
  Widget _buildEmojiAsset(String assetPath) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        assetPath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, size: 14, color: Colors.red),
      );
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> spans = [];
    final text = this.text;
    // Pattern to match emoji codes like :smile:, :cool:, etc.
    final emojiRegex = RegExp(r':(\w+):');
    int lastIndex = 0;

    for (final match in emojiRegex.allMatches(text)) {
      // Add text before emoji
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style ?? TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ));
      }

      // Add emoji as widget or as text if not found
      final emojiCode = ':${match.group(1)}:';
      final asset = emojiAssets[emojiCode];

      if (asset != null) {
        // Render emoji as image
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: SizedBox(
              width: 22,
              height: 22,
              child: _buildEmojiAsset(asset),
            ),
          ),
        ));
      } else {
        // If emoji not found, show as text code (for debugging, shows what's available)
        spans.add(TextSpan(
          text: emojiCode,
          style: style ?? TextStyle(
            color: isDark ? Colors.grey : Colors.grey,
            fontSize: 14,
          ),
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style ?? TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ));
    }

    return TextSpan(
      style: style,
      children: spans.isEmpty
          ? [TextSpan(text: text, style: style)]
          : spans,
    );
  }
}
