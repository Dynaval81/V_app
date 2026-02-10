import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/glass_kit.dart';
import '../utils/emoji_text_controller.dart';
import '../theme_provider.dart';
import '../constants/app_constants.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatId;
  final String? chatName;
  final bool isGroupChat; // Добавляем параметр для определения типа чата
  const ChatRoomScreen({Key? key, required this.chatId, this.chatName, this.isGroupChat = false}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late EmojiTextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<double> _headerOpacity = ValueNotifier(0.0);
  double _lastOffset = 0.0;
  
  // Primary emoji collection (Main set - all 40 SVG icons from set 2)
  final Map<String, String> _primaryEmojis = {
    ':smile:': 'assets/emojis_v2/icon_e_smile.svg',
    ':arrow:': 'assets/emojis_v2/icon_arrow.svg',
    ':clap:': 'assets/emojis_v2/icon_clap.svg',
    ':cool:': 'assets/emojis_v2/icon_cool.svg',
    ':crazy:': 'assets/emojis_v2/icon_crazy.svg',
    ':cry:': 'assets/emojis_v2/icon_cry.svg',
    ':biggrin:': 'assets/emojis_v2/icon_e_biggrin.svg',
    ':confused:': 'assets/emojis_v2/icon_e_confused.svg',
    ':geek:': 'assets/emojis_v2/icon_e_geek.svg',
    ':sad:': 'assets/emojis_v2/icon_e_sad.svg',
    ':surprised:': 'assets/emojis_v2/icon_e_surprised.svg',
    ':ugeek:': 'assets/emojis_v2/icon_e_ugeek.svg',
    ':wink:': 'assets/emojis_v2/icon_e_wink.svg',
    ':eek:': 'assets/emojis_v2/icon_eek.svg',
    ':eh:': 'assets/emojis_v2/icon_eh.svg',
    ':evil:': 'assets/emojis_v2/icon_evil.svg',
    ':exclaim:': 'assets/emojis_v2/icon_exclaim.svg',
    ':idea:': 'assets/emojis_v2/icon_idea.svg',
    ':lol:': 'assets/emojis_v2/icon_lol.svg',
    ':lolno:': 'assets/emojis_v2/icon_lolno.svg',
    ':mad:': 'assets/emojis_v2/icon_mad.svg',
    ':mrgreen:': 'assets/emojis_v2/icon_mrgreen.svg',
    ':neutral:': 'assets/emojis_v2/icon_neutral.svg',
    ':problem:': 'assets/emojis_v2/icon_problem.svg',
    ':question:': 'assets/emojis_v2/icon_question.svg',
    ':razz:': 'assets/emojis_v2/icon_razz.svg',
    ':redface:': 'assets/emojis_v2/icon_redface.svg',
    ':rolleyes:': 'assets/emojis_v2/icon_rolleyes.svg',
    ':shh:': 'assets/emojis_v2/icon_shh.svg',
    ':shifty:': 'assets/emojis_v2/icon_shifty.svg',
    ':sick:': 'assets/emojis_v2/icon_sick.svg',
    ':silent:': 'assets/emojis_v2/icon_silent.svg',
    ':think:': 'assets/emojis_v2/icon_think.svg',
    ':thumbdown:': 'assets/emojis_v2/icon_thumbdown.svg',
    ':thumbup:': 'assets/emojis_v2/icon_thumbup.svg',
    ':twisted:': 'assets/emojis_v2/icon_twisted.svg',
    ':wave:': 'assets/emojis_v2/icon_wave.svg',
    ':wtf:': 'assets/emojis_v2/icon_wtf.svg',
    ':yawn:': 'assets/emojis_v2/icon_yawn.svg',
    ':angel:': 'assets/emojis_v2/icon_angel.svg',
  };

  // Retro emoji collection (8-бит ретро - supplementary set with classic GIF style)
  final Map<String, String> _retroEmojis = {
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
      emojiAssets: _primaryEmojis,
      retroAssets: _retroEmojis,
      isDark: false,
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Только обновлять при значимых изменениях (debounce: >5px)
    if ((offset - _lastOffset).abs() > 5.0) {
      _lastOffset = offset;
      final newOpacity = (offset / 100).clamp(0.0, 1.0);
      if ((newOpacity - _headerOpacity.value).abs() > 0.05) {
        _headerOpacity.value = newOpacity;
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _headerOpacity.dispose();
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

  void _startVideoCall() {
    // TODO: Реализовать видеозвонок
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Видеозвонок с ${widget.chatName ?? 'Chat Room ${widget.chatId}'}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startAudioCall() {
    // TODO: Реализовать аудиозвонок
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Аудиозвонок с ${widget.chatName ?? 'Chat Room ${widget.chatId}'}'),
        backgroundColor: Colors.green,
      ),
    );
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

  // Robust emoji parsing with support for [retro] prefix
  InlineSpan _buildTextWithEmojis(String text, bool isDark) {
    final List<InlineSpan> spans = [];
    // Match both [retro]:code: and :code: patterns
    final regex = RegExp(r'(\[retro\])?:(\w+):');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        ));
      }

      final isRetro = match.group(1) != null; // Check for [retro] prefix
      final code = ':${match.group(2)}:';
      
      // Select emoji from appropriate collection
      final emojisMap = isRetro ? _retroEmojis : _primaryEmojis;
      final asset = emojisMap[code];
      
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
        // Show full match if emoji not found
        spans.add(TextSpan(
          text: '${isRetro ? '[retro]' : ''}$code',
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
    String selectedCollection = 'primary'; // Track selected collection in modal
    
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
                // Collection tabs - Primary and Retro 8-bit
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCollectionTab(
                          isDark,
                          'Primary',
                          'primary',
                          selectedCollection,
                          () => setModalState(() => selectedCollection = 'primary'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCollectionTab(
                          isDark,
                          '8-бит Ретро',
                          'retro',
                          selectedCollection,
                          () => setModalState(() => selectedCollection = 'retro'),
                        ),
                      ),
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
                      children: _getEmojisByCollection(selectedCollection).entries.map((e) {
                        final code = e.key;
                        final asset = e.value;
                        // Add [retro] prefix for retro collection
                        final insertCode = selectedCollection == 'retro' ? '[retro]$code' : code;
                        
                        return GestureDetector(
                          onTap: () {
                            _messageController.text = '${_messageController.text} $insertCode';
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

  // Helper to get emojis by collection
  Map<String, String> _getEmojisByCollection(String collection) {
    return collection == 'primary' ? _primaryEmojis : _retroEmojis;
  }

  // Collection tab widget
  Widget _buildCollectionTab(
    bool isDark,
    String collectionName,
    String collectionId,
    String selectedCollection,
    Function onTap,
  ) {
    final isActive = selectedCollection == collectionId;
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          collectionName,
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
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
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Единая шапка в стиле VTALK (точная копия общих чатов)
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent, // Как в общих чатах
                  elevation: 0,
                  flexibleSpace: GlassKit.liquidGlass(
                    radius: 0, // Как в общих чатах
                    isDark: isDark,
                    opacity: 0.3, // Как в общих чатах
                    useBlur: true, // Как в общих чатах
                    child: Container(),
                  ),
                  title: Row(
                    children: [
                      // Кнопка назад вместо иконки blur_on
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      
                      // Аватар контакта
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          "${AppConstants.defaultAvatarUrl}?u=${widget.chatId}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Имя контакта
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chatName ?? 'Chat Room ${widget.chatId}',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // Кнопки вызова только для личных чатов
                    if (!widget.isGroupChat) ...[
                      ValueListenableBuilder<double>(
                        valueListenable: _headerOpacity,
                        builder: (context, opacity, _) {
                          return IconButton(
                            icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => _startVideoCall(),
                          );
                        },
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: _headerOpacity,
                        builder: (context, opacity, _) {
                          return IconButton(
                            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => _startAudioCall(),
                          );
                        },
                      ),
                    ],
                    const SizedBox(width: 16),
                  ],
                ),
                
                // Messages
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200, // Высота для сообщений
                    child: ListView.builder(
                      // Убираем controller - он уже используется в CustomScrollView
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
                ),

                // Input field
                SliverToBoxAdapter(
                  child: Padding(
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
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
