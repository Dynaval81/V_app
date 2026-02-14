import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/models/message_model.dart';
import '../../../data/mock/mock_messages.dart';
import '../../../core/providers/chat_provider.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input.dart';

/// 📱 Chat Room Screen - HI3 Layer 4
/// Individual chat view with message thread and input
class ChatRoomScreen extends ConsumerStatefulWidget {
  final ChatRoom chat;

  const ChatRoomScreen({
    super.key,
    required this.chat,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  late bool hasUnread;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    hasUnread = widget.chat.unread > 0;
    if (hasUnread) {
      ref.read(chatProvider.notifier).markAsRead(widget.chat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatMessages = chatState.messages.where((m) => m.chatId == widget.chat.id).toList();

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
              itemCount: chatMessages.length + (hasUnread ? 1 : 0),
              itemBuilder: (context, index) {
                if (hasUnread && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        const SizedBox(width: 8),
                        Text(
                          "NEW MESSAGES",
                          style: TextStyle(color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  );
                }
                final messageIndex = hasUnread ? index - 1 : index;
                final message = chatMessages[messageIndex];
                return MessageBubble(message: message, isMe: message.isMe);
              },
            ),
          ),
          // Input Field
          ChatInput(
            onSendMessage: (text) {
              ref.read(chatProvider.notifier).sendMessage(widget.chat.id, text);
            },
          ),
        ],
      ),
    );
  }
}
