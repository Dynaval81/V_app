import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';

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
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar("Vtalk AI"),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildAiBubble(_messages[index].text, _messages[index].isUser);
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Text(
          "AI is thinking...", 
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54, 
            fontSize: 12
          )
        );
      },
    ),
                  ),
                ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("always online", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ],
              ),
              CircleAvatar(radius: 22, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=ai")),
            ],
          ),
        );
      },
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
