import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../utils/emoji_text_controller.dart';
import '../theme_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatId;
  const ChatRoomScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late EmojiTextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Local emoji assets map - complete list of all available emojis
  final Map<String, String> _emojiAssets = {
    ':smile:': 'assets/emojis/smiley.gif',
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
    ':kiss:': 'assets/emojis/kiss.gif',
    ':lipssealed:': 'assets/emojis/lipsrsealed.gif',
    ':mario:': 'assets/emojis/mario.gif',
    ':pacman:': 'assets/emojis/pacman.gif',
    ':police:': 'assets/emojis/police.gif',
    ':rolleyes:': 'assets/emojis/rolleyes.gif',
    ':sad2:': 'assets/emojis/sad2.gif',
    ':shrug:': 'assets/emojis/shrug.gif',
    ':undecided:': 'assets/emojis/undecided.gif',
  };

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Привет! Посмотри на наши новые GIF :smile:', 'isMe': false, 'time': '12:30'},
    {'text': 'Это работает мгновенно через Assets! :cool:', 'isMe': true, 'time': '12:31'},
  ];

  @override
  void initState() {
    super.initState();
    _messageController = EmojiTextEditingController(
      emojiAssets: _emojiAssets,
      isDark: false, // Will be updated in build method
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
    });

    _messageController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  // Robust emoji parsing using RegExp.allMatches
  InlineSpan _buildTextWithEmojis(String text, bool isDark) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r':(\w+):');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ));
      }

      final code = ':${match.group(1)}:';
      final asset = _emojiAssets[code];
      if (asset != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Icon(Icons.broken_image, size: 16, color: Colors.red),
              ),
            ),
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: code,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
      ));
    }

    return TextSpan(children: spans);
  }

  void _showEmojiPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        isDark: isDark,
        useBlur: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emojiAssets.entries.map((e) {
              final code = e.key;
              final asset = e.value;
              return GestureDetector(
                onTap: () {
                  _messageController.text = '${_messageController.text} $code';
                  Navigator.pop(context);
                  _focusNode.requestFocus();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.emoji_emotions, size: 28),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(code.replaceAll(':', ''), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    _messageController.updateTheme(isDark); // Update theme in emoji controller

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: GlassKit.mainBackground(isDark),
          child: SafeArea(
            child: Column(
              children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Chat Room ${widget.chatId}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black), onPressed: () {}),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    final isMe = m['isMe'] as bool;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: GlassKit.liquidGlass(
                        isDark: isDark,
                        useBlur: false,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: RichText(text: _buildTextWithEmojis(m['text'] as String, isDark)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.white70 : Colors.black54),
                      onPressed: () => _showEmojiPicker(isDark),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          filled: true,
                          fillColor: isDark ? Colors.white10 : Colors.black12,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: Icon(Icons.send, color: Colors.blueAccent), onPressed: _sendMessage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
