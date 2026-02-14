import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/chat_room.dart';
import '../../../core/constants/app_constants.dart';

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

    return Theme(
      data: Theme.of(context).copyWith(brightness: Brightness.light),
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final chat = suggestions[index];
          return ListTile(
            title: Text(chat.name ?? 'Unknown'),
            onTap: () {
              close(context, '');
              if (chat.id != null) {
                context.push('${AppRoutes.chat}/${chat.id}');
              }
            },
          );
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    final filteredChats = chats.where((chat) {
      return chat.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).take(5).toList();

    return Theme(
      data: Theme.of(context).copyWith(brightness: Brightness.light),
      child: ListView.builder(
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chat = filteredChats[index];
          return ListTile(
            title: Text(chat.name ?? 'Unknown'),
            onTap: () {
              close(context, '');
              if (chat.id != null) {
                context.push('${AppRoutes.chat}/${chat.id}');
              }
            },
          );
        },
      ),
    );
  }
}
