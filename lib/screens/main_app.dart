import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tabs/chats_screen.dart';
import 'tabs/vpn_screen.dart';
import 'tabs/ai_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/badged_icon.dart';
import 'auth/register_screen.dart';

class MainApp extends StatefulWidget {
  final int initialTab;

  MainApp({this.initialTab = 0});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late int _currentIndex;
  late List<Widget> _screens;
  bool _isDark = true; // Глобальная переменная темы

  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _screens = [
      DashboardScreen(isDark: _isDark, onTabSwitch: (index) {
        setState(() { _currentIndex = index; });
      }), // index 0
      ChatsScreen(isDark: _isDark), // index 1
      VPNScreen(isDark: _isDark),  // index 2
      AIScreen(isDark: _isDark),   // index 3
    ];
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDark = value;
      // Обновляем все экраны с новой темой
      _screens = [
        DashboardScreen(isDark: _isDark, onTabSwitch: (index) {
          setState(() { _currentIndex = index; });
        }),
        ChatsScreen(isDark: _isDark),
        VPNScreen(isDark: _isDark),
        AIScreen(isDark: _isDark),
      ];
    });
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _showProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString('user_nickname') ?? 'User';
    final email = prefs.getString('user_email') ?? 'user@example.com';
    final vtalkNumber = prefs.getString('vtalk_number') ?? 'VT-0000';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                nickname[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              nickname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              vtalkNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSearch() async {
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Color(0xFF252541),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
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
      icon: Icon(Icons.arrow_back),
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
          color: Theme.of(context).textTheme.bodyLarge?.color,
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
      'Charlie Brown',
      'Settings',
      'VPN Connection',
      'AI Assistant',
    ].where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.search),
          title: Text(suggestions.elementAt(index)),
          onTap: () {
            query = suggestions.elementAt(index);
            showResults(context);
          },
        );
      },
    );
  }
}