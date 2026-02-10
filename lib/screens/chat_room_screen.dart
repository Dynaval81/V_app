import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  
  // Variant selection
  String _emojiVariant = 'original'; // 'original', 'v1', 'v2'

  // Original set emoji assets
  final Map<String, String> _emojiAssetsOriginal = {
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

  // V1 set emoji assets
  final Map<String, String> _emojiAssetsV1 = {
    ':smile:': 'assets/emojis_v1/smile.gif',
    ':cool:': 'assets/emojis_v1/cool.gif',
    ':shock:': 'assets/emojis_v1/surprised.gif',
    ':tongue:': 'assets/emojis_v1/tongueout.gif',
    ':heart:': 'assets/emojis_v1/kiss.gif',
    ':sad:': 'assets/emojis_v1/sad.gif',
    ':angry:': 'assets/emojis_v1/mad.gif',
    ':grin:': 'assets/emojis_v1/laughing.gif',
    ':wink:': 'assets/emojis_v1/winkblink.gif',
    ':cry:': 'assets/emojis_v1/crying.gif',
    ':laugh:': 'assets/emojis_v1/laughing.gif',
    ':evil:': 'assets/emojis_v1/devil.gif',
    ':afro:': 'assets/emojis_v1/angel.gif',
    ':angel:': 'assets/emojis_v1/angel.gif',
    ':azn:': 'assets/emojis_v1/smile.gif',
    ':bang:': 'assets/emojis_v1/scream.gif',
    ':blank:': 'assets/emojis_v1/nothingtosay.gif',
    ':buenpost:': 'assets/emojis_v1/thumbsup.gif',
    ':cheesy:': 'assets/emojis_v1/laughing.gif',
    ':embarrassed:': 'assets/emojis_v1/blushing.gif',
    ':huh:': 'assets/emojis_v1/surprised.gif',
    ':kiss:': 'assets/emojis_v1/kiss.gif',
    ':lipssealed:': 'assets/emojis_v1/shutup.gif',
    ':mario:': 'assets/emojis_v1/thumbsup.gif',
    ':pacman:': 'assets/emojis_v1/smile.gif',
    ':police:': 'assets/emojis_v1/cool.gif',
    ':rolleyes:': 'assets/emojis_v1/nothingtosay.gif',
    ':sad2:': 'assets/emojis_v1/crying.gif',
    ':shrug:': 'assets/emojis_v1/nothingtosay.gif',
    ':undecided:': 'assets/emojis_v1/question.gif',
  };

  // V2 set emoji assets (SVG)
  final Map<String, String> _emojiAssetsV2 = {
    ':smile:': 'assets/emojis_v2/icon_e_smile.svg',
    ':cool:': 'assets/emojis_v2/icon_cool.svg',
    ':shock:': 'assets/emojis_v2/icon_e_surprised.svg',
    ':tongue:': 'assets/emojis_v2/icon_razz.svg',
    ':heart:': 'assets/emojis_v2/icon_lol.svg',
    ':sad:': 'assets/emojis_v2/icon_e_sad.svg',
    ':angry:': 'assets/emojis_v2/icon_mad.svg',
    ':grin:': 'assets/emojis_v2/icon_biggrin.svg',
    ':wink:': 'assets/emojis_v2/icon_e_wink.svg',
    ':cry:': 'assets/emojis_v2/icon_e_sad.svg',
    ':laugh:': 'assets/emojis_v2/icon_lol.svg',
    ':evil:': 'assets/emojis_v2/icon_evil.svg',
    ':afro:': 'assets/emojis_v2/icon_angel.svg',
    ':angel:': 'assets/emojis_v2/icon_angel.svg',
    ':azn:': 'assets/emojis_v2/icon_e_geek.svg',
    ':bang:': 'assets/emojis_v2/icon_exclaim.svg',
    ':blank:': 'assets/emojis_v2/icon_neutral.svg',
    ':buenpost:': 'assets/emojis_v2/icon_thumbup.svg',
    ':cheesy:': 'assets/emojis_v2/icon_lol.svg',
    ':embarrassed:': 'assets/emojis_v2/icon_redface.svg',
    ':huh:': 'assets/emojis_v2/icon_eh.svg',
    ':kiss:': 'assets/emojis_v2/icon_kiss.svg',
    ':lipssealed:': 'assets/emojis_v2/icon_shh.svg',
    ':mario:': 'assets/emojis_v2/icon_thumbup.svg',
    ':pacman:': 'assets/emojis_v2/icon_lol.svg',
    ':police:': 'assets/emojis_v2/icon_cool.svg',
    ':rolleyes:': 'assets/emojis_v2/icon_rolleyes.svg',
    ':sad2:': 'assets/emojis_v2/icon_e_sad.svg',
    ':shrug:': 'assets/emojis_v2/icon_shrug.svg',
    ':undecided:': 'assets/emojis_v2/icon_question.svg',
  };

  // Get active emoji map based on current variant
  Map<String, String> get _currentEmojiAssets {
    switch (_emojiVariant) {
      case 'v1':
        return _emojiAssetsV1;
      case 'v2':
        return _emojiAssetsV2;
      default:
        return _emojiAssetsOriginal;
    }
  }

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Привет! Посмотри на наши новые GIF :smile:', 'isMe': false, 'time': '12:30'},
    {'text': 'Это работает мгновенно через Assets! :cool:', 'isMe': true, 'time': '12:31'},
  ];

  @override
  void initState() {
    super.initState();
    _messageController = EmojiTextEditingController(
      emojiAssets: _currentEmojiAssets,
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

  // Helper function to render emoji asset as GIF or SVG
  Widget _buildEmojiWidget(String assetPath, {double width = 28, double height = 28}) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => Icon(Icons.broken_image, size: width * 0.8, color: Colors.red),
      );
    }
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
      final asset = _currentEmojiAssets[code];
      if (asset != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              width: 28,
              height: 28,
              child: _buildEmojiWidget(asset, width: 28, height: 28),
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
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassKit.liquidGlass(
          radius: 30,
          isDark: isDark,
          useBlur: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Variant selector tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildVariantButton(isDark, 'Original', 'original', setModalState),
                      const SizedBox(width: 8),
                      _buildVariantButton(isDark, 'Variant 1', 'v1', setModalState),
                      const SizedBox(width: 8),
                      _buildVariantButton(isDark, 'Variant 2', 'v2', setModalState),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 12),
                // Emojis grid
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentEmojiAssets.entries.map((e) {
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
                                child: _buildEmojiWidget(asset, width: 36, height: 36),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariantButton(bool isDark, String label, String variant, Function setModalState) {
    final isActive = _emojiVariant == variant;
    return GestureDetector(
      onTap: () {
        setState(() {
          _emojiVariant = variant;
          _messageController.emojiAssets = _currentEmojiAssets;
        });
        setModalState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
