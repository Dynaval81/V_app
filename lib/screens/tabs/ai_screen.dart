import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/glass_kit.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  ChatMessage({required this.text, required this.isUser, this.imageUrl});
}

class AIScreen extends StatefulWidget {
  final bool isDark;
  AIScreen({this.isDark = true});
  
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final Random _random = Random();
  bool isDark = true;

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
    return Scaffold(
      body: Container(
        decoration: GlassKit.mainBackground(widget.isDark),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar("AI Studio"),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: ChatMessageWidget(message: _messages[index], isDark: widget.isDark),
                    );
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "AI is thinking...", 
                      style: TextStyle(
                        color: widget.isDark ? Colors.white54 : Colors.black54, 
                        fontSize: 12
                      )
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
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("always online", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
            ],
          ),
          CircleAvatar(radius: 22, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=ai")),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
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
                  style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Message or /draw...", 
                    hintStyle: TextStyle(
                      color: widget.isDark ? Colors.white54 : Colors.black54
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

  Widget _aiAction(IconData i, String l, Color c) => Column(
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
          color: widget.isDark ? Colors.white70 : Colors.black54, 
          fontSize: 12
        )
      ),
    ],
  );
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  ChatMessageWidget({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) 
            CircleAvatar(
              radius: 18, 
              backgroundColor: Colors.purple.withOpacity(0.2), 
              child: Icon(Icons.auto_awesome, size: 14, color: Colors.purpleAccent)
            ),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GlassKit.liquidGlass(
                  radius: 15,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      message.text, 
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black
                      )
                    ),
                  ),
                ),
                // Если есть URL картинки — показываем её
                if (message.imageUrl != null)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 250,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(message.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}