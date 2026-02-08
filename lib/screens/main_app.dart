import 'package:flutter/material.dart';
import 'tabs/chats_screen.dart';
import 'tabs/vpn_screen.dart';
import 'tabs/ai_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/badged_icon.dart';
import '../constants/app_colors.dart';

class MainApp extends StatefulWidget {
  final int initialTab;

  MainApp({this.initialTab = 0});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = [
    ChatsScreen(),
    VPNScreen(),
    AIScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.disabledTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: BadgedIcon(
              icon: Icons.chat_bubble_outline,
              badgeCount: 3, // Mock
            ),
            activeIcon: BadgedIcon(
              icon: Icons.chat_bubble,
              badgeCount: 3,
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key_outlined),
            activeIcon: Icon(Icons.vpn_key),
            label: 'VPN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}