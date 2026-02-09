import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'tabs/chats_screen.dart';
import 'tabs/vpn_screen.dart';
import 'tabs/ai_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/badged_icon.dart';
import '../constants/app_constants.dart';
import '../theme_provider.dart';

class MainApp extends StatefulWidget {
  final int initialTab;

  MainApp({this.initialTab = 0});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // ПРАВИЛЬНЫЙ ПОРЯДОК ВКЛАДОК
  List<Widget> get _screens => [
    const ChatsScreen(),      // 0. Мессенджер (Первый)
    const VPNScreen(),        // 1. VPN
    const AIScreen(),         // 2. Vtalk AI
    DashboardScreen(          // 3. Dashboard (Последний)
      onTabSwitch: (i) => setState(() => _currentIndex = i),
    ),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _showProfile() async {
    final nickname = await _secureStorage.read(key: AppConstants.userNicknameKey) ?? 'User';
    final email = await _secureStorage.read(key: AppConstants.userEmailKey) ?? 'user@example.com';
    final vtalkNumber = await _secureStorage.read(key: AppConstants.vtalkNumberKey) ?? 'VT-0000';

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
                nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _changeTab,
            backgroundColor: themeProvider.isDarkMode ? Color(0xFF252541) : Color(0xFFF5F5F5),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
              BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Vtalk AI'),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
            ],
          ),
        );
      },
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: Text(
            'Search results for: $query',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
              leading: Icon(Icons.search, color: themeProvider.isDarkMode ? Colors.blue : Colors.blue),
              title: Text(
                suggestions.elementAt(index),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                query = suggestions.elementAt(index);
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
