import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';

/// 📱 Message Bubble - HI3 Atomic Widget
/// Material 3 Bubbles following FluffyChat design
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isPreviousFromSameSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isPreviousFromSameSender = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: isPreviousFromSameSender ? 2 : 12,
        left: 16,
        right: 16,
        bottom: 2,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(18),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
