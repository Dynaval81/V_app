import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/chat_room.dart';
import '../../../core/constants/app_constants.dart';

/// 📱 Chat Search Delegate
class ChatSearchDelegate extends SearchDelegate<String> {
  final List<ChatRoom> chats;

  ChatSearchDelegate({required this.chats});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          close(context, '');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = chats.where((chat) {
      return chat.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return ListTile(
          title: Text(chat.name ?? 'Unknown'),
          onTap: () {
            close(context, '');
            // Navigate to the selected chat
            if (chat.id != null) {
              context.push('${AppRoutes.chat}/${chat.id}');
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // Return empty container when query is empty - do not show full list
      return Container();
    }

    final suggestions = chats.where((chat) {
      return chat.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).take(5).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return ListTile(
          title: Text(chat.name ?? 'Unknown'),
          onTap: () {
            close(context, '');
            // Navigate to the selected chat
            if (chat.id != null) {
              context.push('${AppRoutes.chat}/${chat.id}');
            }
          },
        );
      },
    );
  }
}
