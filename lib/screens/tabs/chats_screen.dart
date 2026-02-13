import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../chat_room_screen.dart';
import '../account_settings_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _searchOpacity = ValueNotifier(0.0);
  double _lastOffset = 0.0;
  // Simple in-memory storage for newly created chats/groups in this session
  final List<Map<String, dynamic>> _customChats = [];
  
  // User status storage
  String _userStatus = "at work / traveling";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Только обновлять при значимых изменениях (debounce: >5px)
    if ((offset - _lastOffset).abs() > 5.0) {
      _lastOffset = offset;
      final newOpacity = (offset / 80).clamp(0.0, 1.0);
      if ((newOpacity - _searchOpacity.value).abs() > 0.05) {
        _searchOpacity.value = newOpacity;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchOpacity.dispose();
    super.dispose();
  }

  void _showSearch(BuildContext context, bool isDark) {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(isDark: isDark),
      query: '',
    );
  }

  void _showCreateChatForm({required bool isGroup}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final nameCtrl = TextEditingController();
            final descriptionCtrl = TextEditingController();
            final searchCtrl = TextEditingController();
            final selectedParticipants = <String>[];
            final availableContacts = [
              'Alice Johnson', 'Bob Smith', 'Charlie Brown', 'Diana Prince',
              'Eva Green', 'Frank White', 'Grace Hopper', 'Henry Ford',
            ];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassKit.liquidGlass(
                radius: 32,
                useBlur: true,
                isDark: isDark,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isGroup ? 'Create Group' : 'New Chat',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isGroup)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameCtrl,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Group Name',
                              labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              prefixIcon: Icon(Icons.group, color: Colors.blueAccent),
                              filled: true,
                              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: descriptionCtrl,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Group Description',
                              labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              prefixIcon: Icon(Icons.description, color: Colors.blueAccent),
                              filled: true,
                              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              hintText: 'What\'s this group about?',
                            ),
                            maxLines: 2,
                            maxLength: 100,
                          ),
                        ],
                      ),

                    if (!isGroup)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: searchCtrl,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Search contact',
                              labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                              filled: true,
                              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              hintText: '@username or name',
                              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedParticipants.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedParticipants.map((participant) {
                                  return Chip(
                                    label: Text(participant),
                                    backgroundColor: Colors.blueAccent,
                                    labelStyle: const TextStyle(color: Colors.white),
                                    deleteIcon: GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          selectedParticipants.remove(participant);
                                        });
                                      },
                                      child: Icon(Icons.close, size: 16, color: Colors.blueAccent),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
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
                                          Text(
                                            contact,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (isGroup) {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a group name')),
                                );
                                return;
                              }
                              if (selectedParticipants.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select at least one participant')),
                                );
                                return;
                              }
                              setState(() {
                                _customChats.insert(0, {
                                  'id': DateTime.now().millisecondsSinceEpoch.remainder(1000000),
                                  'name': name,
                                  'isGroup': true,
                                  'isOnline': true,
                                  'unread': 0,
                                  'participants': List<String>.from(selectedParticipants),
                                });
                              });
                            } else {
                              final foundContact = searchCtrl.text.trim();
                              if (foundContact.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a valid contact')),
                                );
                                return;
                              }
                              setState(() {
                                _customChats.insert(0, {
                                  'id': DateTime.now().millisecondsSinceEpoch.remainder(1000000),
                                  'name': foundContact,
                                  'isGroup': false,
                                  'isOnline': true,
                                  'unread': 0,
                                  'contact': foundContact,
                                });
                              });
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.done),
                          label: Text(isGroup ? 'Create Group' : 'Create Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: foundContact.isNotEmpty || isGroup ? Colors.blueAccent : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomChatTile(Map<String, dynamic> chat, bool isDark) {
    final isGroup = chat['isGroup'] as bool? ?? false;
    final isOnline = chat['isOnline'] as bool? ?? false;
    final unreadCount = chat['unread'] as int? ?? 0;

    return GlassKit.liquidGlass(
      context: context,
      useBlur: false,
      radius: 16,
      opacity: 0.05,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatRoomScreen(
            chatId: chat['id'] as int, 
            chatName: chat['name'] as String,
            isGroupChat: false,
          )),
        ),
        leading: Stack(
          children: [
            CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider("${AppConstants.defaultAvatarUrl}?u=custom${chat['id']}"),),
            if (!isGroup && isOnline)
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
                chat['name'] as String,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        ),
        subtitle: Text(
            isGroup ? "Group description..." : _userStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GlassKit.mainBackground(isDark),
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark 
                        ? Colors.transparent
                        : Colors.white,
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.08),
                              blurRadius: 15, 
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Image.asset(
                    'assets/images/app_logo_mercury.png',
                    height: 54,
                    width: 54,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("TALK", style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 20,
                  )),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search), 
                onPressed: () => _showSearch(context, isDark),
                color: isDark ? Colors.white : Colors.black87,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: CachedNetworkImageProvider("${AppConstants.defaultAvatarUrl}?u=me"),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                expandedHeight: 120,
                flexibleSpace: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Chats',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _userStatus,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildStatusEditButton(isDark),
                      ],
                    ),
                  ],
                ),
                actions: [
                  ValueListenableBuilder(
                    valueListenable: _searchOpacity,
                    builder: (context, child) {
                      return AnimatedOpacity(
                        opacity: _searchOpacity.value,
                        duration: const Duration(milliseconds: 200),
                        child: child!,
                      );
                    },
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCreateChatForm(isGroup: false),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _searchOpacity,
                    builder: (context, child) {
                      return AnimatedOpacity(
                        opacity: _searchOpacity.value,
                        duration: const Duration(milliseconds: 200),
                        child: child!,
                      );
                    },
                    child: IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: () => _showCreateChatForm(isGroup: true),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: _customChats.length + 1,
                    builder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'No chats yet',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first chat to get started',
                                style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.black45,
                                      fontSize: 14,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (index < _customChats.length) {
                        final chat = _customChats[index - 1];
                        return _buildCustomChatTile(chat, isDark);
                      }
                      
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusEditButton(bool isDark) {
    return IconButton(
      icon: Icon(Icons.edit, size: 16, color: isDark ? Colors.white54 : Colors.black54),
      onPressed: () => _showStatusEditDialog(isDark),
      tooltip: 'Edit Status',
    );
  }

  void _showStatusEditDialog(bool isDark) {
    final TextEditingController statusController = TextEditingController(text: _userStatus);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        title: Text(
          'Edit Status',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: statusController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter your status...',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _userStatus = statusController.text.trim();
              });
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final bool isDark;
  List<dynamic> searchResults = [];
  bool isLoading = false;

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
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.white : Colors.black,
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          'No users found for: $query',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['avatar'] ?? 'https://i.pravatar.cc/150?u=${user['username']}'),
          ),
          title: Text(
            user['username'] ?? user['email'] ?? 'Unknown',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            user['email'] ?? '',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  chatId: user['id'] ?? user['matrixUserId'] ?? 0,
                  chatName: user['username'] ?? user['email'] ?? 'Unknown',
                  isGroupChat: false,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      _performSearch(query);
    }

    return Container();
  }

  void _performSearch(String query) async {
    if (isLoading) return;
    
    isLoading = true;
    searchResults = [];

    try {
      final authService = AuthService();
      final result = await authService.searchUsers(query);
      
      isLoading = false;
      if (result['success']) {
        searchResults = result['users'] ?? [];
      } else {
        searchResults = [];
      }
    } catch (e) {
      isLoading = false;
      searchResults = [];
    }
  }
}
