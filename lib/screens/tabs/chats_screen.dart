import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../chat_room_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _appBarDensity = 0.0;
  double _titleOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    setState(() {
      _appBarDensity = (offset / 100).clamp(0.0, 0.7);
      _titleOpacity = (1.0 - (offset / 60)).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent, // Фон прозрачный, чтобы работал Blur
                elevation: 0,
                // Динамическая плотность стекла
                flexibleSpace: GlassKit.liquidGlass(
                  radius: 0,
                  isDark: isDark, // Передаем текущую тему!
                  opacity: _appBarDensity > 0.1 ? 0.4 : 0.0, // Резкое появление плотности, как в Telegram
                  child: Container(),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.blur_on, color: Colors.blueAccent, size: 32),
                    const SizedBox(width: 8),
                    // Название плавно исчезает, оставляя лого
                    Opacity(
                      opacity: _titleOpacity,
                      child: Text("VTALK", style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 20
                      )),
                    ),
                  ],
                ),
                actions: [
                  // Лупа только когда название скрыто
                  if (_titleOpacity < 0.3)
                    IconButton(
                      icon: const Icon(Icons.search), 
                      onPressed: () => _showSearch(context, isDark),
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  CircleAvatar(
                    radius: 18, 
                    backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me")
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassKit.liquidGlass(
                    radius: 15,
                    child: TextField(
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Search chats...",
                        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildChatTile(index, isDark),
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(int i, bool isDark) {
    bool isGroup = i % 3 == 0;
    bool isOnline = i % 4 == 0;
    int unreadCount = i % 5 == 0 ? (i % 7 + 1) : 0;
    
    return ListTile(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ChatRoomScreen(chatId: i))
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28, 
            backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=chat$i")
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          if (isGroup) 
            Icon(Icons.group, size: 16, color: Colors.blueAccent),
          if (isGroup) const SizedBox(width: 6),
          Expanded(
            child: Text(
              isGroup ? "Project Group $i" : "Contact $i", 
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
      subtitle: Text(
        isOnline ? "Online" : "Offline", 
        style: TextStyle(
          color: isOnline ? Colors.green.withOpacity(0.7) : Colors.grey.withOpacity(0.7), 
          fontSize: 12
        )
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("${12 + (i % 12)}:${45 + (i % 15)}", 
               style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
          const SizedBox(height: 4),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueAccent, 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                unreadCount > 99 ? "99+" : unreadCount.toString(), 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, bool isDark) {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(isDark: isDark),
    );
  }
}

// Делегат для поиска в чатах
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
    return Center(
      child: Text(
        'Search results for: $query',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Alice Johnson',
      'Bob Smith',
      'Project Group',
      'Charlie Brown',
      'VPN Connection',
      'AI Assistant',
    ].where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.search, color: isDark ? Colors.blue : Colors.blue),
          title: Text(
            suggestions.elementAt(index),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {
            query = suggestions.elementAt(index);
            showResults(context);
          },
        );
      },
    );
  }
}
