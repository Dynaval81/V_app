import 'package:flutter/material.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/models/message_model.dart';
import '../../../data/mock/mock_messages.dart';
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
  late List<MessageModel> chatMessages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatMessages = mockMessages.where((m) => m.chatId == widget.chat.id).toList();
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.chat.name}'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'online',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
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
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[chatMessages.length - 1 - index]; // Reverse order
                final isMe = message.senderId == 'me';
                final isPreviousFromSameSender = index > 0
                    ? chatMessages[chatMessages.length - index].senderId == message.senderId
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
              mockMessages.add(newMessage);
              setState(() {
                chatMessages.add(newMessage);
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
