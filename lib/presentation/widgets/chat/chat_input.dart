import 'package:flutter/material.dart';

/// 📱 Chat Input - HI3 Atomic Widget
/// Bottom bar with attachment, text field, and voice/send icon
class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInput({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              // Attachment Icon
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.grey),
                onPressed: () {
                  // TODO: Implement attachment picker
                },
              ),
              // Text Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isTyping = value.isNotEmpty;
                      });
                    },
                  ),
                ),
              ),
              // Voice/Send Icon
              IconButton(
                icon: Icon(
                  _isTyping ? Icons.send : Icons.mic,
                  color: _isTyping ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                onPressed: _isTyping
                    ? () {
                        if (_controller.text.isNotEmpty) {
                          widget.onSendMessage(_controller.text);
                          _controller.clear();
                          setState(() {
                            _isTyping = false;
                          });
                        }
                      }
                    : () {
                        // TODO: Implement voice recording
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
