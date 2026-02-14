import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../widgets/airy_chat_header.dart';
import '../widgets/airy_chat_list_item.dart';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      
      // ➕ Create Chat FAB with message icon
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.message, size: 24), // Message icon for new chat
      ),
      
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🎨 Glassmorphism header with search
              AiryChatHeader(
                title: 'Чаты', // Russian title as requested
                action: IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: theme.brightness == Brightness.dark 
                        ? Color(0xFF121212) 
                        : Color(0xFF000000),
                    size: 24,
                  ),
                  onPressed: _toggleSearch,
                ),
              ),
              
              // 🔍 Search bar (shown when searching)
              if (_isSearching)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AiryInputField(
                      controller: _searchController,
                      label: 'Search chats',
                      hint: 'Type to search...',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        ref.read(chatProvider.notifier).searchChatRooms(value);
                      },
                    ),
                  ),
                ),
              
              // 📱 Chat list with structured items
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16), // Reduced from 16 to 12
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chatRoom = chatRooms[index];
                      final isSelected = chatState.selectedChatRoomId == chatRoom.id;
                      
                      return AiryChatListItem(
                        chatRoom: chatRoom,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(chatProvider.notifier).selectChatRoom(chatRoom.id);
                          // Navigate to individual chat
                          context.go('${AppRoutes.chat}/${chatRoom.id}');
                        },
                      );
                    },
                    childCount: chatRooms.length,
                  ),
                ),
              ),
              
              // TODO: Temporarily commented out for debugging
              /*
              // 📱 Loading indicator
              if (chatState.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenPadding),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary,
                      ),
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
