import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/vtalk_header.dart';
import '../account_settings_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  ChatMessage({required this.text, required this.isUser, this.imageUrl});
}

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});
  
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final Random _random = Random();

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isTyping = false;
        // Если сообщение начинается с /draw, имитируем генерацию картинки
        if (text.toLowerCase().startsWith('/draw')) {
          _messages.add(ChatMessage(
            text: "Generating: ${text.replaceFirst('/draw', '')}",
            isUser: false,
            imageUrl: "https://picsum.photos/seed/${_random.nextInt(1000)}/400/300", // Рандомная картинка
          ));
        } else {
          _messages.add(ChatMessage(text: _generateAIResponse(text), isUser: false));
        }
      });
      _scrollToBottom();
    }
  }

  String _generateAIResponse(String userText) {
    return "I received your message: '$userText'. I'm currently in preview mode. Matrix integration coming in v0.2!";
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // (removed unused compat adapter)

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              VtalkHeader(
                title: 'Vtalk AI',
                showScrollAnimation: false,
                scrollController: null, // Без анимации скролла
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me"),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Чем я могу тебе помочь?',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Actions grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _aiTile(Icons.image, 'Создать изображение', Colors.purpleAccent, () => _onAction('create_image')),
                          _aiTile(Icons.photo_library, 'Редактировать фото', Colors.orangeAccent, () => _onAction('edit_photo')),
                          _aiTile(Icons.text_snippet, 'Улучшить текст', Colors.teal, () => _onAction('improve_text')),
                          _aiTile(Icons.translate, 'Перевести текст', Colors.indigo, () => _onAction('translate')),
                          _aiTile(Icons.help_outline, 'Объяснить', Colors.green, () => _onAction('explain')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // small note
                      Center(
                        child: Text(
                          'Выберите действие выше или напишите внизу',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildChatStyleInput(isDark),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return GlassKit.liquidGlass(
          radius: 25,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.auto_awesome, color: Colors.blueAccent),
                  onPressed: () => _showAIActionMenu(),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Message or /draw...", 
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54
                        ), 
                        border: InputBorder.none
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent), 
                  onPressed: () => _handleSubmitted(_textController.text)
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAIActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _aiAction(Icons.brush, "Generate Image", Colors.purpleAccent),
              _aiAction(Icons.photo_filter, "AI Editor", Colors.orangeAccent),
              _aiAction(Icons.face_retouching_natural, "Avatar Maker", Colors.tealAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiAction(IconData i, String l, Color c) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30, 
              backgroundColor: c.withOpacity(0.1), 
              child: Icon(i, color: c, size: 30)
            ),
            SizedBox(height: 8),
            Text(
              l, 
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54, 
                fontSize: 12
              )
            ),
          ],
        );
      },
    );
  }

  Widget _aiTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _onAction(String key) {
    switch (key) {
      case 'create_image':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выбрано: Создать изображение')));
        break;
      case 'edit_photo':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выбрано: Редактировать фото')));
        break;
      case 'improve_text':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выбрано: Улучшить текст')));
        break;
      case 'translate':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выбрано: Перевести текст')));
        break;
      case 'explain':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выбрано: Объяснить')));
        break;
    }
  }

  Widget _buildChatStyleInput(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GlassKit.liquidGlass(
          radius: 25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.auto_awesome, color: Colors.blueAccent),
                  onPressed: _showAIActionMenu,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Напишите сообщение или опишите задачу',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiBubble(String text, bool isUser) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Здесь фикс ширины
            child: GlassKit.liquidGlass(
              radius: 15,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // Не шире 75% экрана
                padding: EdgeInsets.all(16),
                child: Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              ),
            ),
          ),
        );
      },
    );
  }
}
