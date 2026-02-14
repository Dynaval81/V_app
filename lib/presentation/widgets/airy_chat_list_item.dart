import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_room.dart';

/// 📱 Airy Chat List Item - L4 UI Component
/// Telegram-style with 72px height and squircle avatar
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
    final preview = chatService.generateChatPreview(chatRoom.messages ?? []);
    final lastMessage = chatRoom.messages?.isNotEmpty == true 
        ? chatRoom.messages!.last 
        : null;
    final unreadCount = chatService.getUnreadCount(chatRoom, 'current_user_id'); // TODO: Get from auth

    return Container(
      height: 72, // Exact height as requested
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 16px padding
            child: Row(
              children: [
                // 📷 Squircle Avatar (52px height, 18px radius)
                _buildSquircleAvatar(title),
                
                const SizedBox(width: 16), // Spacing between avatar and content
                
                // 📝 Chat content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 👤 Chat title
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          color: Color(0xFF121212),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // 📝 Message preview and time
                      Row(
                        children: [
                          // 💬 Message preview
                          Expanded(
                            child: Text(
                              preview,
                              style: AppTextStyles.body.copyWith(
                                color: Color(0xFF757575), // Gray color as requested
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // ⏰ Time
                          if (lastMessage != null)
                            Text(
                              chatService.formatMessageTime(lastMessage!.timestamp),
                              style: AppTextStyles.body.copyWith(
                                color: Color(0xFF757575), // Thin font as requested
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⏰ Timestamp (top element)
                    if (lastMessage != null)
                      Text(
                        chatService.formatMessageTime(lastMessage!.timestamp),
                        style: AppTextStyles.body.copyWith(
                          color: Color(0xFF757575), // Grey, font size 12-13
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    
                    const SizedBox(height: 4), // ONLY spacer between time and status
                    
                    // 🔴 Status indicator (bottom element)
                    if (showUnreadIndicator)
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

  /// 📷 Build squircle avatar (52px height, 18px radius)
  Widget _buildSquircleAvatar(String title) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Color(0xFF00A3FF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(18), // Squircle shape as requested
        border: Border.all(
          color: Color(0xFF00A3FF).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Slightly smaller for visual appeal
        child: Container(
          color: Color(0xFF00A3FF).withOpacity(0.3),
          child: Center(
            child: Text(
              _getInitials(title),
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
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
