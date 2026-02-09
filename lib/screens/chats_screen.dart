import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import '../widgets/vtalk_header.dart';
import '../constants/app_constants.dart';
import 'chat_room_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showCreateOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        isDark: isDark,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.blue),
                title: const Text('New Chat'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.green),
                title: const Text('Create Group'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, bool isDark, int index) {
    final avatars = [
      AppConstants.avatarUrl,
      '${AppConstants.avatarUrl}2',
      '${AppConstants.avatarUrl}3',
      '${AppConstants.avatarUrl}4',
      '${AppConstants.avatarUrl}5',
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatars[index % avatars.length]),
        backgroundColor: Colors.transparent,
      ),
      title: Text(
        'User ${index + 1}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Last message from user ${index + 1} :smile:',
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${12 + index}:${30 + (index % 60)}',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          if (index % 3 == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(index + 1) * 2}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(chatId: index + 1),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassKit.mainBackground(isDark: isDark),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          VtalkHeader(
            title: 'VTALK',
            showScrollAnimation: true,
            scrollOffset: _scrollOffset,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _scrollOffset > 100 
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: 20,
                builder: (context, index) => _buildChatItem(context, isDark, index),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context, isDark),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
