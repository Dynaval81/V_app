import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_room.dart';
import '../services/chat_service.dart';
import '../../logic/chat_manager.dart';

/// 📊 Chat Provider - L2 State Management
/// Handles chat state with HAI3 architecture compliance
class ChatProvider extends StateNotifier<ChatState> {
  final ChatService _chatService;
  
  ChatProvider(this._chatService) : super(ChatState());

  /// 📱 Load chat rooms
  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        chatRooms: ChatManager.chats,
        messages: ChatManager.messages,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chat rooms: ${e.toString()}',
      );
    }
  }

  /// 📖 Mark messages as read
  void markAsRead(String chatId) {
    ChatManager.markAsRead(chatId);
    state = state.copyWith(chatRooms: ChatManager.chats);
  }
  Future<void> sendMessage(String chatRoomId, String text) async {
    if (!_chatService.validateMessage(text)) {
      state = state.copyWith(error: 'Message validation failed');
      return;
    }

    // Create new message
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _chatService.parseMessageText(text),
      senderId: 'current_user_id', // TODO: Get from auth provider
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Add message to local state immediately
    addMessageToChat(chatRoomId, newMessage);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update message status to sent
      final updatedMessage = newMessage.copyWith(
        status: MessageStatus.sent,
      );
      
      updateMessageInChat(chatRoomId, updatedMessage);
      
      // Clear error if any
      state = state.copyWith(error: null);
    } catch (e) {
      // Update message status to failed
      final failedMessage = newMessage.copyWith(
        status: MessageStatus.failed,
      );
      
      updateMessageInChat(chatRoomId, failedMessage);
      
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
    }
  }

  /// 📝 Search chat rooms
  void searchChatRooms(String query) {
    final filteredRooms = _chatService.filterChatRooms(state.chatRooms, query);
    state = state.copyWith(
      searchQuery: query,
      filteredChatRooms: query.isEmpty ? null : filteredRooms,
    );
  }

  /// 📝 Select chat room
  void selectChatRoom(String chatRoomId) {
    state = state.copyWith(selectedChatRoomId: chatRoomId);
    markAsRead(chatRoomId);
  }

  /// 📝 Clear search
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredChatRooms: null,
    );
  }

  /// 📝 Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 📝 Add message to chat locally
  void addMessageToChat(String chatRoomId, MessageModel message) {
    ChatManager.messages.add(message);
    state = state.copyWith(messages: List.from(ChatManager.messages));
  }

  /// 📝 Update message in chat
  void updateMessageInChat(String chatRoomId, MessageModel updatedMessage) {
    final messageIndex = ChatManager.messages.indexWhere((msg) => msg.id == updatedMessage.id);
    
    if (messageIndex != -1) {
      ChatManager.messages[messageIndex] = updatedMessage;
      state = state.copyWith(messages: List.from(ChatManager.messages));
    }
  }

}

/// 📊 Chat State
class ChatState {
  final List<ChatRoom> chatRooms;
  final List<ChatRoom>? filteredChatRooms;
  final String? selectedChatRoomId;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  List<MessageModel> messages;

  ChatState({
    this.chatRooms = const [],
    this.filteredChatRooms,
    this.selectedChatRoomId,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.messages = const [],
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    List<ChatRoom>? filteredChatRooms,
    String? selectedChatRoomId,
    String? searchQuery,
    bool? isLoading,
    String? error,
    List<MessageModel>? messages,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      filteredChatRooms: filteredChatRooms ?? this.filteredChatRooms,
      selectedChatRoomId: selectedChatRoomId ?? this.selectedChatRoomId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messages: messages ?? this.messages,
    );
  }
}

/// 📊 Chat Provider instance
final chatProvider = StateNotifierProvider<ChatProvider, ChatState>(
  (ref) => ChatProvider(ChatService()),
);
