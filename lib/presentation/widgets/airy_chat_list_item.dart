import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/controllers/chat_controller.dart';
import '../../core/services/chat_service.dart';
import '../../data/models/chat_room.dart';
import '../../data/mock/mock_messages.dart';
import '../screens/chat/chat_room_screen.dart';

class AiryChatListItem extends StatefulWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showUnreadIndicator;

  const AiryChatListItem({
    super.key,
    required this.chatRoom,
    this.onTap,
    this.isSelected = false,
    this.showUnreadIndicator = true,
  });

  @override
  State<AiryChatListItem> createState() => _AiryChatListItemState();
}

class _AiryChatListItemState extends State<AiryChatListItem> {
  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        final unreadCount = chatController.getUnreadCount(widget.chatRoom.id);
        return _buildContent(context, unreadCount);
      },
    );
  }

  Widget _buildContent(BuildContext context, int unreadCount) {
    final chatService = ChatService();
    final title = chatService.generateChatTitle(widget.chatRoom);

    final lastMsg = mockMessages.where((m) => m.chatId == widget.chatRoom.id).toList().lastOrNull;
    final preview = lastMsg?.text ?? "No messages yet";
    final lastMessage = widget.chatRoom.messages?.isNotEmpty == true
        ? widget.chatRoom.messages!.last
        : null;

    return Container(
      height: 88, // Increased height to prevent overflow
      decoration: BoxDecoration(
        color: widget.isSelected 
            ? Color(0xFF00A3FF).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.button),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
                Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => ChatRoomScreen(chat: widget.chatRoom)),
              );
            }
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Content padding as requested
            child: Row(
              children: [
                // 📷 Squircle Avatar (52px height, 18px radius)
                _buildSquircleAvatar(widget.chatRoom),
                
                const SizedBox(width: 12.0), // Spacing between avatar and content
                
                // 📝 Chat content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 👤 Contact name (updated to 20.0)
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16.0, 
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // 📝 Message preview and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 💬 Message preview with status icon
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    preview,
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.grey, // Grey color for last message
                                      fontSize: 15.0, // Updated to 15.0
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lastMsg?.isMe == true)
                                  Icon(
                                    Icons.done_all,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                              ],
                            ),
                          ),
                          // 🕒 Time only
                          SizedBox(
                            width: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lastMsg != null ? formatTime(lastMsg.timestamp) : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 🏰 Trailing widget with structured Column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Keep time and badge perfectly centered
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⏰ Timestamp (top element)
                    if (lastMessage != null)
                      Text(
                        chatService.formatMessageTime(lastMessage.timestamp),
                        style: AppTextStyles.body.copyWith(
                          color: Color(0xFF757575), // Grey, font size 13
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    
                    const SizedBox(height: 4), // ONLY spacer between time and status
                    
                    // 🔴 Status indicator (bottom element)
                    if (unreadCount > 0) // Only show if unreadCount > 0
                      // Unread count badge
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF00A3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (lastMessage != null)
                      // Message status indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (lastMessage.isRead)
                            // Two blue checkmarks (read)
                            Icon(
                              Icons.done_all,
                              color: Color(0xFF00A3FF),
                              size: 16,
                            )
                          else
                            Icon(
                              Icons.done,
                              color: Color(0xFF757575),
                              size: 16,
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📷 Build squircle avatar
  Widget _buildSquircleAvatar(ChatRoom chatRoom) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: CircleAvatar(
        radius: 20, // Unified radius
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${chatRoom.name}'),
      ),
    );
  }

  /// 📝 Get initials from title
  String _getInitials(String title) {
    final parts = title.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

/// 📱 Airy Chat List Separator (16px spacing only)
class AiryChatListSeparator extends StatelessWidget {
  const AiryChatListSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16); // Only spacing, no divider lines
  }
}
