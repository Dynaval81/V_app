import 'package:flutter/foundation.dart';
import 'package:vtalk_app/data/models/chat_model.dart';
import 'package:vtalk_app/logic/chat_manager.dart';

/// Core controller for chat list state (HAI3).
/// Manages list of [ChatModel] and notifies listeners so UI updates instantly.
class ChatController extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<ChatModel> get chats => List.unmodifiable(_chats);

  /// Loads chats from [ChatManager] and notifies. Call once at startup or when list is refreshed.
  void loadChats() {
    _chats = ChatManager.chats
        .map((room) => ChatModel.fromChatRoom(room))
        .toList();
    notifyListeners();
  }

  /// Syncs from current [ChatManager.chats] (e.g. after provider loaded). Idempotent by id.
  void syncFromChatManager() {
    final byId = {for (var c in _chats) c.id: c};
    for (final room in ChatManager.chats) {
      final existing = byId[room.id];
      if (existing != null) {
        existing.unreadCount = room.unread;
      } else {
        _chats.add(ChatModel.fromChatRoom(room));
      }
    }
    notifyListeners();
  }

  /// Marks the chat as read and notifies so the unread badge disappears without reload.
  void markAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index >= 0) {
      _chats[index].markAsRead();
      ChatManager.markAsRead(chatId);
      notifyListeners();
    }
  }

  /// Returns current unread count for [chatId]; 0 if not found.
  int getUnreadCount(String chatId) {
    try {
      return _chats.firstWhere((c) => c.id == chatId).unreadCount;
    } catch (_) {
      return 0;
    }
  }
}
