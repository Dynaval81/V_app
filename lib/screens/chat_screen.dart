import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;

  ChatScreen({required this.chatName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: 'Hey! How are you?',
      isMine: false,
      timestamp: '10:30',
    ),
    Message(
      text: 'I\'m good, thanks! How about you?',
      isMine: true,
      timestamp: '10:31',
    ),
    Message(
      text: 'Great! Want to grab coffee later?',
      isMine: false,
      timestamp: '10:32',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.purple,
              child: Text(
                widget.chatName.isNotEmpty 
                    ? widget.chatName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              widget.chatName,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.phone,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isMine
              ? Colors.blue
              : (Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF252541)
                  : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: message.isMine ? Radius.circular(16) : Radius.circular(4),
            bottomRight: message.isMine ? Radius.circular(4) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMine
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timestamp,
                  style: TextStyle(
                    color: message.isMine
                        ? Colors.white70
                        : Colors.grey,
                    fontSize: 11,
                  ),
                ),
                if (message.isMine) ...[
                  SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _messages.add(Message(
                    text: _messageController.text,
                    isMine: true,
                    timestamp: TimeOfDay.now().format(context),
                  ));
                  _messageController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

// Model для сообщения
class Message {
  final String text;
  final bool isMine;
  final String timestamp;

  Message({
    required this.text,
    required this.isMine,
    required this.timestamp,
  });
}
