import 'package:flutter/material.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/models/message_model.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input.dart';

/// 📱 Chat Room Screen - HI3 Layer 4
/// Individual chat view with message thread and input
class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chat;

  const ChatRoomScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late List<MessageModel> messages;
  final ScrollController _scrollController = ScrollController();

  // Mock messages for demonstration
  List<MessageModel> _getMockMessages(String chatId) {
    return [
      MessageModel(
        id: '1',
        senderId: 'user1',
        text: 'Hey, how are you?',
        chatId: chatId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        type: MessageType.text,
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '2',
        senderId: 'me',
        text: 'I\'m good, thanks! How about you?',
        chatId: chatId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        type: MessageType.text,
        status: MessageStatus.read,
      ),
      MessageModel(
        id: '3',
        senderId: 'me',
        text: 'Doing great! Just working on some projects.',
        chatId: chatId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        type: MessageType.text,
        status: MessageStatus.read,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    messages = _getMockMessages(widget.chat.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.name ?? 'Unknown',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'online',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index]; // Reverse order
                final isMe = message.senderId == 'me';
                final isPreviousFromSameSender = index > 0
                    ? messages[messages.length - index].senderId == message.senderId
                    : false;

                return MessageBubble(
                  message: message,
                  isMe: isMe,
                  isPreviousFromSameSender: isPreviousFromSameSender,
                );
              },
            ),
          ),
          // Input Field
          ChatInput(
            onSendMessage: (content) {
              final newMessage = MessageModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: 'me',
                text: content,
                chatId: widget.chat.id,
                timestamp: DateTime.now(),
                type: MessageType.text,
                status: MessageStatus.sending,
              );
              setState(() {
                messages.add(newMessage);
              });
              // Scroll to bottom
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
