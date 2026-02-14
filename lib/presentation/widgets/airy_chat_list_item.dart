import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_room.dart';

/// 📱 Airy Chat List Item - L4 UI Component
/// Telegram-style with 72px height and squircle avatar
import '../../../data/mock/mock_messages.dart';

class AiryChatListItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ChatService();
    final title = chatService.generateChatTitle(chatRoom);

    // Single source of truth for messages
    final lastMsg = mockMessages.where((m) => m.chatId == chatRoom.id).toList().lastOrNull;
    final preview = lastMsg?.text ?? "No messages yet";
    final lastMessage = chatRoom.messages?.isNotEmpty == true 
        ? chatRoom.messages!.last 
        : null;
    final unreadCount = chatService.getUnreadCount(chatRoom, 'current_user_id'); // TODO: Get from auth

    return Container(
      height: 88, // Increased height to prevent overflow
      decoration: BoxDecoration(
        color: isSelected 
            ? Color(0xFF00A3FF).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.button),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Content padding as requested
            child: Row(
              children: [
                // 📷 Squircle Avatar (52px height, 18px radius)
                _buildSquircleAvatar(chatRoom),
                
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
                          color: Colors.black87, // Black87 for contact name
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0, // Updated to 20.0 (bold)
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
                                      fontSize: 16.0, // Updated to 16.0
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
                          // 🕒 Time and unread badge
                          Row(
                            children: [
                              if (chatRoom.unread != null && chatRoom.unread! > 0)
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      chatRoom.unread.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Text(
                                lastMsg?.timestamp != null
                                  ? DateFormat('HH:mm').format(lastMsg!.timestamp)
                                  : '',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
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
                        chatService.formatMessageTime(lastMessage!.timestamp),
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
                          if (lastMessage!.isRead)
                            // Two blue checkmarks (read)
                            Icon(
                              Icons.done_all,
                              color: Color(0xFF00A3FF),
                              size: 16,
                            )
                          else
                            // One grey checkmark (sent but not read)
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
