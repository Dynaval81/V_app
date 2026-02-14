import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/chat_provider.dart';
import '../widgets/airy_chat_header.dart';
import '../widgets/airy_chat_list_item.dart';
import '../widgets/chat_search_delegate.dart';
import '../../data/models/chat_room.dart';
import '../../../data/models/message_model.dart';
import 'chat_room_screen.dart';

/// 📱 V-Talk Chats Screen - L4 UI Layer
/// Airy design with glassmorphism header and structured chat list
class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock messages for demonstration
  List<MessageModel> _getMockMessages(String chatId) {
    if (chatId == '1') {
      return [
        MessageModel(
          id: '1',
          senderId: 'user1',
          text: 'Hey, how are you?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          type: MessageType.text,
          status: MessageStatus.read,
        ),
        MessageModel(
          id: '2',
          senderId: 'me',
          text: 'I\'m good, thanks! How about you?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          type: MessageType.text,
          status: MessageStatus.read,
        ),
        MessageModel(
          id: '3',
          senderId: 'me',
          text: 'Doing great! Just working on some projects.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
          type: MessageType.text,
          status: MessageStatus.read,
        ),
      ];
    } else if (chatId == '2') {
      return [
        MessageModel(
          id: '1',
          senderId: 'user2',
          text: 'See you tomorrow!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.text,
          status: MessageStatus.read,
        ),
      ];
    } else if (chatId == '3') {
      return [
        MessageModel(
          id: '1',
          senderId: 'user3',
          text: 'Thanks for the help!',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          type: MessageType.text,
          status: MessageStatus.read,
        ),
      ];
    }
    return [];
  }

  // Mock data to prove it works
  final List<ChatRoom> mockChats = [
    ChatRoom(
      id: '1',
      name: 'Alice Johnson',
      unread: 2,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatRoom(
      id: '2',
      name: 'Bob Smith',
      unread: 0,
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatRoom(
      id: '3',
      name: 'Carol Davis',
      unread: 1,
      lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);
    final List<ChatRoom> chatRooms = mockChats.map((chat) => chat.copyWith(messages: _getMockMessages(chat.id))).toList(); // Populate with mock messages
    
    // Debug print to verify data presence
    print('Chat count: ${chatRooms.length}');

    return Scaffold(
      backgroundColor: Colors.white, // Force white background for Telegram Light
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // The Header
          AiryChatHeader(
            title: 'Чаты',
            onSearchPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(chats: chatRooms),
            ),
            onAvatarPressed: () => print("Open Profile"),
          ),
          // The List or Empty State
          chatRooms.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Text(
                    "No messages yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 0), // Full width
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => AiryChatListItem(
                      chatRoom: chatRooms[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => ChatRoomScreen(chat: chatRooms[index])),
                        );
                      },
                    ),
                    childCount: chatRooms.length,
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.message, size: 24), // Message icon for new chat
      ),
    );
  }

  void _createNewChat() {
    // TODO: Implement new chat creation
    print('Create new chat');
  }
}
