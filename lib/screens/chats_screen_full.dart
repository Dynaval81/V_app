import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/vtalk_header.dart';
import '../constants/app_constants.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 50 && !_showSearchIcon) {
      setState(() => _showSearchIcon = true);
    } else if (offset <= 50 && _showSearchIcon) {
      setState(() => _showSearchIcon = false);
    }
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required bool isOnline,
    required int unreadCount,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('${AppConstants.avatarUrl}1'),
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
      onTap: () {
        Navigator.pushNamed(context, '/chat');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [Colors.black87, Colors.black54, Colors.black26]
                : [Colors.white, Colors.white70, Colors.white30],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            VtalkHeader(
              title: 'VTALK',
              showScrollAnimation: true,
              scrollOffset: _scrollController.offset,
              actions: [
                AnimatedOpacity(
                  opacity: _showSearchIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: ChatSearchDelegate(isDark: isDark),
                      );
                    },
                  ),
                ),
                AnimatedOpacity(
                  opacity: _showSearchIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      _showCreateMenu(context);
                    },
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chats = [
                      {'name': 'Alice Johnson', 'message': 'Hey! How are you doing?', 'time': '2:30 PM', 'online': true, 'unread': 2},
                      {'name': 'Bob Smith', 'message': 'See you tomorrow!', 'time': '1:15 PM', 'online': false, 'unread': 0},
                      {'name': 'Carol White', 'message': 'Thanks for the help!', 'time': '12:45 PM', 'online': true, 'unread': 1},
                      {'name': 'David Brown', 'message': 'Can you send me the files?', 'time': '11:30 AM', 'online': false, 'unread': 0},
                      {'name': 'Emma Davis', 'message': 'Great idea! Let\'s do it', 'time': 'Yesterday', 'online': true, 'unread': 3},
                    ];
                    
                    if (index >= chats.length) return null;
                    
                    final chat = chats[index];
                    return _buildChatItem(
                      name: chat['name'] as String,
                      message: chat['message'] as String,
                      time: chat['time'] as String,
                      isOnline: chat['online'] as bool,
                      unreadCount: chat['unread'] as int,
                      isDark: isDark,
                    );
                  },
                  childCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
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
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final bool isDark;

  ChatSearchDelegate({required this.isDark});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: isDark ? Colors.white : Colors.black),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: isDark ? Colors.black87 : Colors.white,
      child: Center(
        child: Text(
          'Search results for: $query',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: isDark ? Colors.black87 : Colors.white,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.history, color: isDark ? Colors.white54 : Colors.black54),
            title: Text('Alice Johnson', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            onTap: () {
              query = 'Alice Johnson';
              showResults(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: isDark ? Colors.white54 : Colors.black54),
            title: Text('Bob Smith', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            onTap: () {
              query = 'Bob Smith';
              showResults(context);
            },
          ),
        ],
      ),
    );
  }
}
