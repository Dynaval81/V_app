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
  // Simple in-memory storage for newly created chats/groups in this session
  final List<Map<String, dynamic>> _customChats = [];

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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMenu,
        child: const Icon(Icons.add),
      ),
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
                  (context, index) {
                    if (index < _customChats.length) {
                      final chat = _customChats[index];
                      return _buildCustomChatTile(chat, isDark);
                    }
                    final generatedIndex = index - _customChats.length;
                    return _buildChatTile(generatedIndex, isDark);
                  },
                  childCount: _customChats.length + 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChatTile(Map<String, dynamic> chat, bool isDark) {
    final isGroup = chat['isGroup'] as bool? ?? false;
    final isOnline = chat['isOnline'] as bool? ?? false;
    final unreadCount = chat['unread'] as int? ?? 0;

    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatRoomScreen(chatId: chat['id'] as int, chatName: chat['name'] as String)),
      ),
      leading: Stack(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=custom${chat['id']}")),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(6))),
            ),
        ],
      ),
      title: Row(
        children: [
          if (isGroup) Icon(Icons.group, size: 16, color: Colors.blueAccent),
          if (isGroup) const SizedBox(width: 6),
          Expanded(child: Text(chat['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
        ],
      ),
      subtitle: Text(isOnline ? 'Online' : 'Offline', style: TextStyle(color: isOnline ? Colors.green.withOpacity(0.7) : Colors.grey.withOpacity(0.7), fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${12}:${45}', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
          const SizedBox(height: 4),
          if (unreadCount > 0)
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)), child: Text(unreadCount > 99 ? '99+' : unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildChatTile(int i, bool isDark) {
    bool isGroup = i % 3 == 0;
    bool isOnline = i % 4 == 0;
    int unreadCount = i % 5 == 0 ? (i % 7 + 1) : 0;
    final chatName = isGroup ? "Project Group $i" : "Contact $i";
    
    return ListTile(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ChatRoomScreen(chatId: i, chatName: chatName))
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

  void _showCreateMenu() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: GlassKit.liquidGlass(
            isDark: isDark,
            radius: 30,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create New',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 12),
                  
                  // New Chat option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateChatForm(isGroup: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_add, color: Colors.blueAccent, size: 24),
                          const SizedBox(width: 14),
                          Text(
                            'New Chat',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // New Group option
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateChatForm(isGroup: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group_add, color: Colors.blueAccent, size: 24),
                          const SizedBox(width: 14),
                          Text(
                            'New Group',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateChatForm({required bool isGroup}) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController contactCtrl = TextEditingController(); // For searching contact
    final Set<String> selectedParticipants = {};
    final List<String> availableContacts = [
      'Alice Johnson',
      'Bob Smith',
      'Charlie Brown',
      'David Lee',
      'Emma Wilson',
      'Frank Miller',
      'Grace Taylor',
      'Henry Davis',
    ];

    showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassKit.liquidGlass(
                isDark: isDark,
                radius: 20,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxHeight: 600),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isGroup ? 'Create New Group' : 'New One-on-One Chat',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.white12 : Colors.black12),
                      const SizedBox(height: 16),

                      // Name field
                      TextField(
                        controller: nameCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: isGroup ? 'Group Name' : 'Chat Name',
                          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                          prefixIcon: Icon(isGroup ? Icons.group : Icons.person, color: Colors.blueAccent),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact search field (only for 1-on-1 chats)
                      if (!isGroup)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Contact',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: contactCtrl,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Search @nick or VT-number',
                                labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                                filled: true,
                                fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                hintText: '@username or VT-123456',
                                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Participants section (only for groups)
                      if (isGroup)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Participants',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Selected participants chips
                              if (selectedParticipants.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Wrap(
                                    spacing: 8,
                                    children: selectedParticipants.map((contact) {
                                      return GlassKit.liquidGlass(
                                        isDark: isDark,
                                        useBlur: false,
                                        radius: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                contact.split(' ')[0],
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    selectedParticipants.remove(contact);
                                                  });
                                                },
                                                child: Icon(Icons.close, size: 16, color: Colors.blueAccent),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              // Contacts list
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: availableContacts.map((contact) {
                                      final isSelected = selectedParticipants.contains(contact);
                                      return GestureDetector(
                                        onTap: () {
                                          setDialogState(() {
                                            if (isSelected) {
                                              selectedParticipants.remove(contact);
                                            } else {
                                              selectedParticipants.add(contact);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blueAccent.withValues(alpha: 0.2)
                                                : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: isSelected
                                                ? Border.all(color: Colors.blueAccent, width: 1.5)
                                                : Border.all(color: Colors.transparent),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage: NetworkImage(
                                                  "${AppConstants.defaultAvatarUrl}?u=${contact.toLowerCase().replaceAll(' ', '')}",
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  contact,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white : Colors.black,
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle, color: Colors.blueAccent, size: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.white12 : Colors.black12),
                      const SizedBox(height: 12),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a name')),
                                );
                                return;
                              }
                              if (!isGroup) {
                                final contact = contactCtrl.text.trim();
                                if (contact.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a contact @nick or VT-number')),
                                  );
                                  return;
                                }
                              }
                              if (isGroup && selectedParticipants.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select at least one participant')),
                                );
                                return;
                              }
                              setState(() {
                                _customChats.insert(0, {
                                  'id': DateTime.now().millisecondsSinceEpoch.remainder(1000000),
                                  'name': name,
                                  'isGroup': isGroup,
                                  'isOnline': true,
                                  'unread': 0,
                                  if (!isGroup) 'contact': contactCtrl.text.trim(),
                                  if (isGroup) 'participants': List<String>.from(selectedParticipants),
                                });
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.done),
                            label: Text(isGroup ? 'Create Group' : 'Create Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
