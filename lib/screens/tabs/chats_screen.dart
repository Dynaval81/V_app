import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../../utils/glass_kit.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
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
  // In-memory chat list (would normally come from backend)
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoadingChats = false;
  
  // User status storage
  String _userStatus = "at work / traveling";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadChatRooms();
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

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoadingChats = true;
    });
    final api = ApiService();
    final result = await api.listChats();
    if (result['success'] == true) {
      final rooms = List<Map<String, dynamic>>.from(result['rooms'] ?? []);
      setState(() {
        _chatRooms = rooms.map((r) {
          return {
            'id': r['id'],
            'name': r['name'] ?? r['title'] ?? '',
            'isGroup': r['isGroup'] ?? false,
            'isOnline': r['isOnline'] ?? true,
            'unread': r['unread'] ?? 0,
          };
        }).toList();
      });
    } else {
      // failed to load, keep empty list or show snackbar
      if (result['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
    setState(() {
      _isLoadingChats = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("MERCURY_DEBUG: FAB НАЖАТ!"); // Крайний тест
          _showCreateMenu();
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true, // ВАЖНО: Позволяет FAB "плавать" над AppBar
                snap: true,     // ВАЖНО: Автоматически показывать/скрывать AppBar
                flexibleSpace: GlassKit.liquidGlass(
                  radius: 0,
                  isDark: isDark,
                  opacity: 0.3,
                  useBlur: true,
                  child: Container(),
                ),
                title: Row(
                  children: [
                    // Mercury Sphere увеличенная с усиленными тенями
                    Container(
                      height: 44, // Увеличиваем с 34 до 44
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.3), // Усиливаем сияние
                            blurRadius: 15, // Больше размытия
                            spreadRadius: 2, // Больше распространения
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/app_logo_mercury.png',
                        height: 44,
                        width: 44,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(width: 8), // Уменьшаем отступ
                    Expanded(
                      child: Text("TALK", style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0, // Растягиваем для премиальности
                        fontSize: 24, // Увеличиваем шрифт
                      )),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search), 
                    onPressed: () => _showSearch(context, isDark),
                    color: isDark ? Colors.white : Colors.black87, // Фиксированный цвет для обеих тем
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
              if (_chatRooms.isEmpty && !_isLoadingChats)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('No chats yet', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 18)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _showSearch(context, isDark),
                          child: const Text('Find first contact'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                if (_isLoadingChats)
                  SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chat = _chatRooms[index];
                        return _buildCustomChatTile(chat, isDark);
                      },
                      childCount: _chatRooms.length,
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

    return GlassKit.liquidGlass(
      context: context, // Добавляем context для debug mode
      useBlur: false, // Отключаем блюр для плавного скролла
      radius: 16,
      opacity: 0.05, // Уменьшаем opacity до уровня Dashboard
      child: ListTile(
        onTap: () async {
          final id = chat['id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomScreen(
              chatId: id,
              chatName: chat['name'] as String,
              isGroupChat: false,
            )),
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider("${AppConstants.defaultAvatarUrl}?u=custom${chat['id']}"),),
            if (!isGroup && isOnline) // Рисуем точку только если это НЕ группа и пользователь онлайн
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
            Expanded(child: Text(chat['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
          ],
        ),
        subtitle: Text(
            isGroup ? "Group description..." : _userStatus, // Используем пользовательский статус
            style: TextStyle(
              fontSize: 11, // Мельче, чем имя
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white54 : Colors.black45, // Приглушенный цвет
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

  void _showSearch(BuildContext context, bool isDark) {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(isDark: isDark),
    );
  }

  void _showCreateMenu() {
  print("MERCURY_DEBUG: Попытка открыть меню!"); // Грязный тест
  
  final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  
  // Добавляем тактильный отклик при открытии
  print("MERCURY_DEBUG: Перед HapticFeedback!"); // Тест
  HapticFeedback.mediumImpact();
  print("MERCURY_DEBUG: После HapticFeedback!"); // Тест
  
  print("MERCURY_DEBUG: Перед showModalBottomSheet!"); // Тест
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Важно для Glass-эффекта
    barrierColor: Colors.black26,       // Легкое затемнение фона
    isScrollControlled: true,
    builder: (context) {
      print("MERCURY_DEBUG: Внутри showModalBottomSheet!"); // Тест
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassKit.liquidGlass(
          radius: 32,
          useBlur: true, // Здесь блюр обязателен!
          isDark: isDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Индикатор для свайпа вниз (Handle)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.chat_bubble_outline_rounded,
                title: "New Chat",
                color: Colors.blueAccent,
                onTap: () {
                  print("MERCURY_DEBUG: New Chat нажат!"); // Тест
                  Navigator.pop(context);
                  _showCreateChatForm(isGroup: false);
                },
              ),
              _buildMenuOption(
                icon: Icons.group_add_outlined,
                title: "Create Group",
                color: Colors.purpleAccent,
                onTap: () {
                  print("MERCURY_DEBUG: Create Group нажат!"); // Тест
                  Navigator.pop(context);
                  _showCreateChatForm(isGroup: true);
                },
              ),
              _buildMenuOption(
                icon: Icons.qr_code_scanner_rounded,
                title: "Scan QR",
                color: Colors.orangeAccent,
                onTap: () {
                  print("MERCURY_DEBUG: Scan QR нажат!"); // Тест
                  Navigator.pop(context);
                  // TODO: Implement QR scanner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('QR Scanner coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
  print("MERCURY_DEBUG: После showModalBottomSheet!"); // Тест
}

Widget _buildMenuOption({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  
  return ListTile(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
    trailing: Icon(
      Icons.chevron_right_rounded, 
      size: 20,
      color: isDark ? Colors.white54 : Colors.black54,
    ),
  );
}

  void _showCreateChatForm({required bool isGroup}) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descriptionCtrl = TextEditingController(); // Добавляем поле для описания группы
    final TextEditingController searchCtrl = TextEditingController();
    final Set<String> selectedParticipants = {};
    String selectedContact = ''; // For 1-on-1 chats (empty until chosen)
    String selectedContactId = ''; // UUID from search result
    // search state
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;
    Timer? _debounce;
    TextEditingController groupSearchCtrl = TextEditingController();

    showDialog(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        final isDark = Provider.of<ThemeProvider>(dialogContext).isDarkMode;
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

                      // Name field (only for groups)
                      if (isGroup)
                        Column(
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
                            // Description field for groups
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

                      // Contact search field (only for 1-on-1 chats)
                      if (!isGroup)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: searchCtrl,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              onChanged: (val) {
                                // debounce search
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 300), () async {
                                  if (val.trim().isEmpty) {
                                    setDialogState(() {
                                      searchResults.clear();
                                      isSearching = false;
                                    });
                                    return;
                                  }
                                  setDialogState(() {
                                    isSearching = true;
                                  });
                                  final result = await AuthService().searchUsers(val.trim());
                                  setDialogState(() {
                                    isSearching = false;
                                    if (result['success'] == true) {
                                      searchResults = List<Map<String, dynamic>>.from(result['users'] ?? []);
                                    } else {
                                      searchResults.clear();
                                    }
                                  });
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Search contact',
                                labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                                filled: true,
                                fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                hintText: '@username or VT number',
                                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Search results or message
                            if (isSearching)
                              Center(child: CircularProgressIndicator())
                            else if (searchCtrl.text.isNotEmpty)
                              ...searchResults.map((userMap) {
                                final name = userMap['username'] ?? '';
                                final vt = userMap['vtNumber'] ?? '';
                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedContact = name;
                                      selectedContactId = userMap['id']?.toString() ?? '';
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: selectedContact == name
                                          ? Colors.blueAccent.withValues(alpha: 0.25)
                                          : Colors.blueAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selectedContact == name ? Colors.blueAccent : Colors.blueAccent.withValues(alpha: 0.3),
                                        width: selectedContact == name ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundImage: NetworkImage(
                                            "${AppConstants.defaultAvatarUrl}?u=$name",
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                vt,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white54 : Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selectedContact == name)
                                          Icon(Icons.check_circle, color: Colors.blueAccent, size: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              const SizedBox(),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Participants section (only for groups)
                      if (isGroup)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search field for group members
                              TextField(
                                controller: groupSearchCtrl,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                onChanged: (val) {
                                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                                  _debounce = Timer(const Duration(milliseconds: 300), () async {
                                    if (val.trim().isEmpty) {
                                      setDialogState(() {
                                        searchResults.clear();
                                        isSearching = false;
                                      });
                                      return;
                                    }
                                    setDialogState(() {
                                      isSearching = true;
                                    });
                                    final result = await AuthService().searchUsers(val.trim());
                                    setDialogState(() {
                                      isSearching = false;
                                      if (result['success'] == true) {
                                        searchResults = List<Map<String, dynamic>>.from(result['users'] ?? []);
                                      } else {
                                        searchResults.clear();
                                      }
                                    });
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Add members',
                                  labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Selected Members',
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
                                    children: selectedParticipants.map((id) {
                                      final user = searchResults.firstWhere(
                                        (u) => u['id']?.toString() == id,
                                        orElse: () => {'username': id, 'vtNumber': ''},
                                      );
                                      final name = user['username'] ?? id;
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
                                                name.split(' ')[0],
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    selectedParticipants.remove(id);
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
                              // Search results
                              if (isSearching)
                                Center(child: CircularProgressIndicator())
                              else if (groupSearchCtrl.text.isNotEmpty)
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: searchResults.map((userMap) {
                                        final name = userMap['username'] ?? '';
                                        final vt = userMap['vtNumber'] ?? '';
                                        final userId = userMap['id']?.toString() ?? '';
                                        final isSelected = selectedParticipants.contains(userId);
                                        return GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              if (isSelected) {
                                                selectedParticipants.remove(userId);
                                              } else {
                                                selectedParticipants.add(userId);
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
                                                    "${AppConstants.defaultAvatarUrl}?u=$name",
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : Colors.black,
                                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                        ),
                                                      ),
                                                      Text(
                                                        vt,
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white54 : Colors.black54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
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
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Type to search members',
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 13,
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
                                // groups are not yet handled by backend; just close dialog
                                // you may refresh list if API supports it later
                                await _loadChatRooms();
                              } else {
                                // 1-on-1 chat
                                if (selectedContact.isEmpty || selectedContactId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a valid contact')),
                                  );
                                  return;
                                }
                                // call backend to create chat
                                final api = ApiService();
                                final result = await api.createChat(selectedContactId);
                                if (result['success'] == true) {
                                  final roomId = result['roomId']?.toString() ?? '';
                                  Navigator.pop(context); // close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatRoomScreen(
                                      chatId: roomId,
                                      chatName: selectedContact,
                                      isGroupChat: false,
                                    )),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['error'] ?? 'Failed to create chat')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.done),
                            label: Text(isGroup ? 'Create Group' : 'Create Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ((selectedContact.isNotEmpty) || isGroup)
                                  ? Colors.blueAccent
                                  : Colors.grey,
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
