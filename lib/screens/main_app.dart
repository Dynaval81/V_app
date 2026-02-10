import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tabs/chats_screen.dart';
import 'tabs/vpn_screen.dart';
import 'tabs/ai_screen.dart';
import 'dashboard_screen.dart';
import '../theme_provider.dart';

class MainApp extends StatefulWidget {
  final int initialTab;

  MainApp({this.initialTab = 0});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // ПРАВИЛЬНЫЙ ПОРЯДОК ВКЛАДОК
  List<Widget> get _screens => [
    const ChatsScreen(),      // 0. Мессенджер (Первый)
    const AIScreen(),         // 1. Vtalk AI
    const VPNScreen(),        // 2. VPN
    DashboardScreen(          // 3. Dashboard (Последний)
      onTabSwitch: (i) => setState(() => _currentIndex = i),
    ),
  ];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Vtalk AI'),
              BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
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
