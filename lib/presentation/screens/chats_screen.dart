import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
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
      backgroundColor: AppColors.surface,
      
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
      
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
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
                    (context, index) {
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
                    childCount: chatRooms.length,
                  ),
                ),
              ),
              
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
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppBorderRadius.button),
                              boxShadow: [AppShadows.md],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.onPrimary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.buttonPadding),
                          Text(
                            'No chats yet',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.inputPadding),
                          Text(
                            'Start a conversation to see it here',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.onSurfaceVariant,
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
            ],
          ),
          
          // Cancel search button overlay
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
        ],
      ),
    );
  }
}
