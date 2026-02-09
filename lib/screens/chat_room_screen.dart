import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import '../constants/app_constants.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatId;
  const ChatRoomScreen({super.key, required this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Маппинг кодов на локальные пути к GIF (только доступные файлы)
  final Map<String, String> _emojiAssets = {
    ':smile:': 'assets/emojis/smiley.gif', // Используем smiley.gif (174 байта)
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
  };

  // Демо сообщения со смайлами (обновлено под доступные)
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Привет! Посмотри на наши новые GIF :smile:', 'isMe': false, 'time': '12:30'},
    {'text': 'Это работает мгновенно через Assets! :cool:', 'isMe': true, 'time': '12:31'},
    {'text': 'Никаких лагов :shock', 'isMe': false, 'time': '12:32'},
    {'text': 'Да! И они работают прямо в сообщениях :wink:', 'isMe': true, 'time': '12:33'},
    {'text': 'Это просто супер! :grin: :laugh:', 'isMe': false, 'time': '12:34'},
    {'text': 'Давай добавим еще эмодзи :heart:', 'isMe': true, 'time': '12:35'},
    {'text': 'Отличная идея! :sad:', 'isMe': false, 'time': '12:36'},
    {'text': 'Иногда я бываю :angry:', 'isMe': true, 'time': '12:37'},
    {'text': 'Но потом :cry:', 'isMe': false, 'time': '12:38'},
    {'text': 'И снова :smile:', 'isMe': true, 'time': '12:39'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMe': true,
        'time': DateTime.now().toString().substring(11, 16),
      });
    });

    _messageController.clear();
    _focusNode.unfocus();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: GlassKit.mainBackground(isDark),
            child: SafeArea(
              child: Column(
                children: [
                  // Шапка чата
                  _buildHeader(context, isDark),
                  
                  // Список сообщений
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(
                          message['text'] as String,
                          message['isMe'] as bool,
                          message['time'] as String,
                          isDark,
                        );
                      },
                    ),
                  ),
                  
                  // Поле ввода
                  _buildInputArea(isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return GlassKit.liquidGlass(
      radius: 0,
      isDark: isDark,
      opacity: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              radius: 20, 
              backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=${widget.chatId}")
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text("Chat Room ${widget.chatId}", style: TextStyle(
                color: isDark ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: 18
              )),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black),
              onPressed: () => _showChatOptions(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Text(
              time,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GlassKit.liquidGlass(
              radius: 18,
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: _parseText(text, isDark),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ДВИЖОК СМАЙЛОВ - локальные GIF с отладкой
  Widget _parseText(String text, bool isDark) {
    if (text.isEmpty) {
      return Text(
        '',
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
      );
    }

    List<InlineSpan> children = [];
    RegExp emojiRegex = RegExp(r':(\w+):');
    List<String> parts = text.split(emojiRegex);
    
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      
      if (part.isNotEmpty && !part.startsWith(':')) {
        // Обычный текст
        children.add(TextSpan(
          text: part,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ));
      } else if (part.startsWith(':') && part.endsWith(':')) {
        // Это может быть смайл
        String emojiCode = part;
        if (_emojiAssets.containsKey(emojiCode)) {
          print('Trying to load: ${_emojiAssets[emojiCode]}'); // Отладка
          children.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Image.asset(
                _emojiAssets[emojiCode]!,
                width: 24, 
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  print('Asset not found: ${_emojiAssets[emojiCode]}'); // Отладка
                  return Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.broken_image, 
                      size: 16, 
                      color: Colors.grey
                    ),
                  );
                },
              ),
            ),
          ));
        } else {
          // Неизвестный код, выводим как текст
          children.add(TextSpan(
            text: emojiCode,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ));
        }
      }
    }

    return RichText(text: TextSpan(children: children));
  }

  Widget _buildInputArea(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassKit.liquidGlass(
        radius: 30,
        isDark: isDark,
        child: Row(
          children: [
            const SizedBox(width: 15),
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.white54 : Colors.black54),
              onPressed: () => _showEmojiPicker(isDark),
            ),
            IconButton(
              icon: Icon(Icons.attach_file, color: isDark ? Colors.white54 : Colors.black54),
              onPressed: () => _showAttachmentOptions(isDark),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        isDark: isDark,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Emoji Picker",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojiAssets.entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _messageController.text += ' ${entry.key}';
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.key.replaceAll(':', ''),
                        style: TextStyle(
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo, color: Colors.blueAccent),
                title: Text("Photo", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.greenAccent),
                title: Text("Video", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.orangeAccent),
                title: Text("Document", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.redAccent),
                title: Text("Location", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info, color: Colors.blueAccent),
                title: Text("Chat Info", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.search, color: Colors.greenAccent),
                title: Text("Search in Chat", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.orangeAccent),
                title: Text("Mute Notifications", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.redAccent),
                title: Text("Block User", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
