import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../constants/app_constants.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required bool isOnline,
    required int unreadCount,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black38,
              fontSize: 12,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'VTALK',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // TODO: Add search functionality
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              _showCreateMenu(context, isDark);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          final chats = [
            {
              'name': 'Alice Johnson',
              'message': 'Hey! How are you doing? 😊',
              'time': '2:30 PM',
              'online': true,
              'unread': 2,
            },
            {
              'name': 'Bob Smith',
              'message': 'See you tomorrow!',
              'time': '1:15 PM',
              'online': false,
              'unread': 0,
            },
            {
              'name': 'Carol White',
              'message': 'Thanks for the help!',
              'time': '12:45 PM',
              'online': true,
              'unread': 1,
            },
            {
              'name': 'David Brown',
              'message': 'Can you send me the files?',
              'time': '11:30 AM',
              'online': false,
              'unread': 0,
            },
            {
              'name': 'Emma Davis',
              'message': 'Great idea! Let\'s do it 🚀',
              'time': 'Yesterday',
              'online': true,
              'unread': 3,
            },
          ];
          
          final chat = chats[index];
          return _buildChatItem(
            name: chat['name'] as String,
            message: chat['message'] as String,
            time: chat['time'] as String,
            isOnline: chat['online'] as bool,
            unreadCount: chat['unread'] as int,
            isDark: isDark,
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
          );
        },
      ),
    );
  }

  void _showCreateMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text('New Chat', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
            ListTile(
              leading: Icon(Icons.group, color: Colors.green),
              title: Text('New Group', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add group creation
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
