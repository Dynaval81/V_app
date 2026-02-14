import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../widgets/airy_chat_header.dart';
import '../widgets/airy_chat_list_item.dart';
import '../widgets/chat_search_delegate.dart';
import '../widgets/airy_input_field.dart';
import '../widgets/airy_button.dart';

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

  @override
  void initState() {
    super.initState();
    // Load initial chat rooms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChatRooms();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(chatProvider.notifier).clearSearch();
      }
    });
  }

  void _createNewChat() {
    // TODO: Navigate to create chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create chat functionality coming soon!'),
        backgroundColor: Color(0xFF00A3FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatRooms = chatState.filteredChatRooms ?? chatState.chatRooms;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
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
          // The List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Full width
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => AiryChatListItem(chat: chatRooms[index]),
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
                  ),
                ),
              
              // 🚨 Error message
              if (chatState.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Color(0xFFFF3B30),
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.screenPadding),
                          Text(
                            chatState.error!,
                            style: AppTextStyles.body.copyWith(
                              color: Color(0xFFFF3B30),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.screenPadding),
                          AiryButton(
                            text: 'Retry',
                            onPressed: () {
                              ref.read(chatProvider.notifier).loadChatRooms();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // 📱 Empty state
              if (!chatState.isLoading && chatRooms.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                              colors: [Color(0xFF00A3FF), Color(0xFF0066FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                              borderRadius: BorderRadius.circular(AppBorderRadius.button),
                              boxShadow: [AppShadows.md],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.buttonPadding),
                          Text(
                            'No chats yet',
                            style: AppTextStyles.h3.copyWith(
                              color: Color(0xFF121212),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.inputPadding),
                          Text(
                            'Start a conversation to see it here',
                            style: AppTextStyles.body.copyWith(
                              color: Color(0xFF757575),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.buttonPadding),
                          AiryButton(
                            text: 'Start Chat',
                            onPressed: () {
                              // TODO: Open new chat creation
                            },
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              */
            ],
          ),
        ],
      ),
    );
  }
}
