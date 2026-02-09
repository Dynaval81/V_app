import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;

  // Оптимизированный маппинг смайлов с эмодзи
  final Map<String, String> _emojiMap = {
    ':smile:': '😊',
    ':sad:': '😢',
    ':shock:': '😮',
    ':cool:': '😎',
    ':tongue:': '😛',
    ':heart:': '❤️',
    ':thumbsup:': '👍',
    ':thumbsdown:': '👎',
    ':fire:': '🔥',
    ':star:': '⭐',
    ':check:': '✅',
    ':x:': '❌',
    ':warning:': '⚠️',
    ':info:': 'ℹ️',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 60 && !_showSearchIcon) {
        setState(() => _showSearchIcon = true);
      } else if (_scrollController.offset <= 60 && _showSearchIcon) {
        setState(() => _showSearchIcon = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Оптимизированная функция парсинга смайлов
  Widget _parseMessage(String text, bool isDark) {
    if (text.isEmpty) {
      return Text(
        '',
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
      );
    }

    List<InlineSpan> spans = [];
    RegExp emojiRegex = RegExp(r':(\w+):');
    List<String> parts = text.split(emojiRegex);
    
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      
      if (part.isNotEmpty && !part.startsWith(':')) {
        // Обычный текст
        spans.add(TextSpan(
          text: part,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
        ));
      } else if (part.startsWith(':') && part.endsWith(':')) {
        // Это может быть смайл
        String emojiCode = part;
        if (_emojiMap.containsKey(emojiCode)) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                _emojiMap[emojiCode]!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ));
        } else {
          // Неизвестный код, выводим как текст
          spans.add(TextSpan(
            text: emojiCode,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
          ));
        }
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: GlassKit.mainBackground(isDark),
            child: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ИНТЕРАКТИВНАЯ ШАПКА
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: 70,
                    centerTitle: false,
                    title: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showSearchIcon
                          ? Icon(Icons.search, color: isDark ? Colors.white : Colors.black)
                          : Text("Vtalk", 
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 26
                              )
                            ),
                    ),
                    actions: [
                      if (_showSearchIcon)
                        IconButton(
                          icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                          onPressed: () => _showSearch(context, isDark),
                        ),
                      CircleAvatar(
                        radius: 18, 
                        backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me")
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  // ПОИСК
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GlassKit.liquidGlass(
                        radius: 15,
                        child: TextField(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "Search chats & groups...",
                            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // СПИСОК ЧАТОВ
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () => _showCreateMenu(context, isDark),
            child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildChatTile(int i, bool isDark) {
    // Демонстрация разных типов чатов со смайлами
    final List<String> messages = [
      "Hello! How are you? :smile:",
      "I am so :shock: about the news! :fire:",
      "Check this out :cool: :thumbsup:",
      "Working on project... :smile: :star:",
      "Don't be :sad: my friend :heart:",
      "Great job! :check: :thumbsup:",
      "Meeting at 3pm :info:",
      "Be careful :warning:",
      "This is awesome :fire: :cool:",
      "Thanks for help :thumbsup: :heart:",
      "Let's celebrate :star: :smile:",
      "Good luck! :thumbsup:",
      "Amazing work :check: :star:",
      "See you later :smile:",
      "Have a great day :heart: :smile:",
    ];

    bool isGroup = i % 3 == 0;
    bool isOnline = i % 4 == 0;
    int unreadCount = i % 5 == 0 ? (i % 7 + 1) : 0;
    
    return ListTile(
      onTap: () => _openChat(i, isDark),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=chat$i"),
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
              isGroup ? "Project Group $i" : "Contact Name $i",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: _parseMessage(messages[i % messages.length], isDark),
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

  void _openChat(int chatId, bool isDark) {
    // TODO: Navigate to chat screen
    print('Opening chat $chatId');
  }

  void _showSearch(BuildContext context, bool isDark) {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(isDark: isDark),
    );
  }

  void _showCreateMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blueAccent),
                title: Text("New Private Chat", 
                     style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _createNewChat(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add, color: Colors.greenAccent),
                title: Text("New Group Instance", 
                     style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _createNewChat(true);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewChat(bool isGroup) {
    // TODO: Implement chat creation
    print('Creating new ${isGroup ? "group" : "private"} chat');
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
      'Alice Johnson :smile:',
      'Bob Smith :cool:',
      'Project Group :star:',
      'Charlie Brown :thumbsup:',
      'VPN Connection :info:',
      'AI Assistant :robot:',
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
