import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers/chat_provider.dart';
import '../widgets/airy_chat_header.dart';
import '../widgets/airy_chat_list_item.dart';
import '../widgets/airy_input_field.dart';
import '../widgets/airy_button.dart';

/// 📱 V-Talk Chats Screen - L4 UI Layer
/// Airy design with glassmorphism header and clean list
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
    // Load chat rooms on init
    Future.microtask(() {
      ref.read(chatProvider.notifier).loadChatRooms();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatRooms = chatState.filteredChatRooms ?? chatState.chatRooms;
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background as requested
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 🎨 Glassmorphism header
          AiryChatHeader(
            title: 'Чаты', // Russian title as requested
            onEditPressed: () {
              // TODO: Open new chat creation
            },
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
          
          // 📱 Chat list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: chatRooms.length,
                builder: (context, index) {
                  final chatRoom = chatRooms[index];
                  final isSelected = chatState.selectedChatRoomId == chatRoom.id;
                  
                  return AiryChatListItem(
                    chatRoom: chatRoom,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(chatProvider.notifier).selectChatRoom(chatRoom.id);
                      // TODO: Navigate to chat room
                    },
                  );
                },
              ),
            ),
          ),
          
          // 📱 Loading indicator
          if (chatState.isLoading)
            const SliverFillRemaining(
              hasOverscroll: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          
          // 🚨 Error message
          if (chatState.error != null)
            SliverFillRemaining(
              hasOverscroll: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        chatState.error!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
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
              hasOverscroll: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          boxShadow: [AppShadows.md],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.onPrimary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No chats yet',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Start a conversation to see it here',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
        ],
      ),
      
      // 🔍 Floating search button
      floatingActionButton: !_isSearching
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
                _searchController.clear();
                ref.read(chatProvider.notifier).clearSearch();
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 4,
              child: const Icon(Icons.search),
            )
          : null,
      
      // ❌ Cancel search button (when searching)
      floatingActionButtonLocation: _isSearching
          ? FloatingActionButtonLocation.startTop
          : FloatingActionButtonLocation.endFloat,
      
      // 🔄 Cancel search FAB
      if (_isSearching)
        Positioned(
          top: 100, // Position below header
          left: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _isSearching = false;
              });
              _searchController.clear();
              ref.read(chatProvider.notifier).clearSearch();
            },
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            elevation: 2,
            child: const Icon(Icons.close),
          ),
        ),
    );
  }
}
