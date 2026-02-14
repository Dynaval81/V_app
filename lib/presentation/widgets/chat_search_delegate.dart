import 'package:flutter/material.dart';

/// 📱 Chat Search Delegate
class ChatSearchDelegate extends SearchDelegate<String> {
  final List<dynamic> chats; // Use dynamic for now

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
      final chatTitle = chat.toString().toLowerCase();
      return chatTitle.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return ListTile(
          title: Text(chat.toString()),
          onTap: () {
            close(context, chat.toString());
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = chats.where((chat) {
      final chatTitle = chat.toString().toLowerCase();
      return chatTitle.contains(query.toLowerCase());
    }).take(5).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final chat = suggestions[index];
        return ListTile(
          title: Text(chat.toString()),
          onTap: () {
            close(context, chat.toString());
          },
        );
      },
    );
  }
}
