import 'package:flutter/material.dart';
import '../chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock данные для чатов
    final List<ChatItem> _chats = [
      ChatItem(
        name: 'Alice',
        lastMessage: 'Hey! How are you?',
        timestamp: '10:30',
        unreadCount: 2,
        avatarColor: Colors.purple,
        isPinned: true,
      ),
      ChatItem(
        name: 'Bob',
        lastMessage: 'Check out this link...',
        timestamp: 'Yesterday',
        unreadCount: 0,
        avatarColor: Colors.blue,
        isPinned: false,
      ),
      ChatItem(
        name: 'Charlie',
        lastMessage: 'See you tomorrow!',
        timestamp: 'Monday',
        unreadCount: 5,
        avatarColor: Colors.green,
        isPinned: false,
      ),
      ChatItem(
        name: 'David',
        lastMessage: 'Thanks for the help!',
        timestamp: 'Sunday',
        unreadCount: 0,
        avatarColor: Colors.orange,
        isPinned: false,
      ),
      ChatItem(
        name: 'Eve',
        lastMessage: 'Meeting at 3pm',
        timestamp: 'Saturday',
        unreadCount: 1,
        avatarColor: Colors.red,
        isPinned: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Messages", 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        // Убрали лупу отсюда!
      ),
      body: Column(
        children: [
          // 1. Поиск (одна лупа)
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintText: "Search contacts...",
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          // 2. Статусы контактов (Любимая фишка молодежи)
          Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: 8,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30, 
                          backgroundColor: Colors.blueAccent, 
                          child: CircleAvatar(
                            radius: 27, 
                            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index")
                          )
                        ),
                        Positioned(
                          right: 2, 
                          bottom: 2, 
                          child: Container(
                            width: 12, 
                            height: 12, 
                            decoration: BoxDecoration(
                              color: Colors.green, 
                              shape: BoxShape.circle, 
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor, 
                                width: 2
                              )
                            )
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "User $index", 
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
                        fontSize: 10
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Список чатов
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) => _buildChatItem(context, _chats[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatItem chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatName: chat.name),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: chat.avatarColor,
                  child: Text(
                    chat.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (chat.isPinned)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.push_pin,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        chat.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model для чата
class ChatItem {
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final Color avatarColor;
  final bool isPinned;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.avatarColor,
    required this.isPinned,
  });
}