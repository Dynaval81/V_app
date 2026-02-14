import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import '../../data/models/user_model.dart';

/// 📊 Chat Provider - L2 State Management
/// Handles chat state with HAI3 architecture compliance
class ChatProvider extends StateNotifier<ChatState> {
  final ChatService _chatService;
  
  ChatProvider(this._chatService) : super(const ChatState());

  /// 📱 Load chat rooms
  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for testing
      final mockChatRooms = _generateMockChatRooms();
      
      state = state.copyWith(
        chatRooms: mockChatRooms,
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

  /// 📝 Send message
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
    _addMessageToChat(chatRoomId, newMessage);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update message status to sent
      final updatedMessage = newMessage.copyWith(
        status: MessageStatus.sent,
      );
      
      _updateMessageInChat(chatRoomId, updatedMessage);
      
      // Clear error if any
      state = state.copyWith(error: null);
    } catch (e) {
      // Update message status to failed
      final failedMessage = newMessage.copyWith(
        status: MessageStatus.failed,
      );
      
      _updateMessageInChat(chatRoomId, failedMessage);
      
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
    }
  }

  /// 📝 Mark chat as read
  void markChatAsRead(String chatRoomId) {
    final chatRooms = List<ChatRoom>.from(state.chatRooms);
    final chatIndex = chatRooms.indexWhere((chat) => chat.id == chatRoomId);
    
    if (chatIndex != -1) {
      final chat = chatRooms[chatIndex];
      _chatService.markMessagesAsRead(chat, 'current_user_id'); // TODO: Get from auth provider
      
      chatRooms[chatIndex] = chat;
      
      state = state.copyWith(chatRooms: chatRooms);
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
    markChatAsRead(chatRoomId);
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
  void _addMessageToChat(String chatRoomId, MessageModel message) {
    final chatRooms = List<ChatRoom>.from(state.chatRooms);
    final chatIndex = chatRooms.indexWhere((chat) => chat.id == chatRoomId);
    
    if (chatIndex != -1) {
      final chat = chatRooms[chatIndex];
      final messages = List<MessageModel>.from(chat.messages ?? []);
      messages.add(message);
      
      final updatedChat = chat.copyWith(
        messages: messages,
        lastActivity: message.timestamp,
      );
      
      chatRooms[chatIndex] = updatedChat;
      
      // Sort chat rooms by activity
      final sortedRooms = _chatService.sortChatRoomsByActivity(chatRooms);
      
      state = state.copyWith(chatRooms: sortedRooms);
    }
  }

  /// 📝 Update message in chat
  void _updateMessageInChat(String chatRoomId, MessageModel updatedMessage) {
    final chatRooms = List<ChatRoom>.from(state.chatRooms);
    final chatIndex = chatRooms.indexWhere((chat) => chat.id == chatRoomId);
    
    if (chatIndex != -1) {
      final chat = chatRooms[chatIndex];
      final messages = List<MessageModel>.from(chat.messages ?? []);
      final messageIndex = messages.indexWhere((msg) => msg.id == updatedMessage.id);
      
      if (messageIndex != -1) {
        messages[messageIndex] = updatedMessage;
        
        final updatedChat = chat.copyWith(messages: messages);
        chatRooms[chatIndex] = updatedChat;
        
        state = state.copyWith(chatRooms: chatRooms);
      }
    }
  }

  /// 📝 Generate mock chat rooms for testing
  List<ChatRoom> _generateMockChatRooms() {
    return [
      ChatRoom(
        id: '1',
        name: 'Alice Johnson',
        participants: [
          {'id': 'current_user_id', 'name': 'You'},
          {'id': 'alice_id', 'name': 'Alice Johnson'},
        ],
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
        messages: [
          MessageModel(
            id: '1',
            text: _chatService.parseMessageText('Hey! How are you doing? 😊'),
            senderId: 'alice_id',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            status: MessageStatus.read,
            isRead: true,
          ),
          MessageModel(
            id: '2',
            text: _chatService.parseMessageText('Hi Alice! I\'m doing great, thanks for asking! 🎉'),
            senderId: 'current_user_id',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
            status: MessageStatus.read,
            isRead: true,
          ),
          MessageModel(
            id: '3',
            text: _chatService.parseMessageText('That\'s wonderful! Want to grab coffee sometime? ☕'),
            senderId: 'alice_id',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            status: MessageStatus.delivered,
            isRead: false,
          ),
        ],
      ),
      ChatRoom(
        id: '2',
        name: 'Bob Smith',
        participants: [
          {'id': 'current_user_id', 'name': 'You'},
          {'id': 'bob_id', 'name': 'Bob Smith'},
        ],
        lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
        messages: [
          MessageModel(
            id: '4',
            text: _chatService.parseMessageText('Did you see the game last night? 🏈'),
            senderId: 'bob_id',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            status: MessageStatus.read,
            isRead: true,
          ),
          MessageModel(
            id: '5',
            text: _chatService.parseMessageText('Yeah! Amazing comeback! 🎯'),
            senderId: 'current_user_id',
            timestamp: DateTime.now().subtract(const Duration(minutes: 58)),
            status: MessageStatus.read,
            isRead: true,
          ),
        ],
      ),
      ChatRoom(
        id: '3',
        name: 'V-Talk Team',
        participants: [
          {'id': 'current_user_id', 'name': 'You'},
          {'id': 'team_member_1', 'name': 'Carol'},
          {'id': 'team_member_2', 'name': 'David'},
          {'id': 'team_member_3', 'name': 'Eve'},
        ],
        lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
        messages: [
          MessageModel(
            id: '6',
            text: _chatService.parseMessageText('Great work on the new features everyone! 🚀'),
            senderId: 'team_member_1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            status: MessageStatus.read,
            isRead: true,
          ),
          MessageModel(
            id: '7',
            text: _chatService.parseMessageText('Thanks! The HAI3 architecture is really paying off 🎨'),
            senderId: 'current_user_id',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
            status: MessageStatus.read,
            isRead: true,
          ),
        ],
      ),
      ChatRoom(
        id: '4',
        name: 'Emma Wilson',
        participants: [
          {'id': 'current_user_id', 'name': 'You'},
          {'id': 'emma_id', 'name': 'Emma Wilson'},
        ],
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
        messages: [
          MessageModel(
            id: '8',
            text: _chatService.parseMessageText('Happy birthday! 🎂🎉'),
            senderId: 'emma_id',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: MessageStatus.read,
            isRead: true,
          ),
          MessageModel(
            id: '9',
            text: _chatService.parseMessageText('Thank you so much! 🥰'),
            senderId: 'current_user_id',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: MessageStatus.read,
            isRead: true,
          ),
        ],
      ),
    ];
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

  const ChatState({
    this.chatRooms = const [],
    this.filteredChatRooms,
    this.selectedChatRoomId,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    List<ChatRoom>? filteredChatRooms,
    String? selectedChatRoomId,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      filteredChatRooms: filteredChatRooms ?? this.filteredChatRooms,
      selectedChatRoomId: selectedChatRoomId ?? this.selectedChatRoomId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 📊 Chat Provider instance
final chatProvider = StateNotifierProvider<ChatProvider, ChatState>(
  (ref) => ChatProvider(ChatService()),
);
