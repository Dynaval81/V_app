import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/constants/app_colors.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:vtalk_app/presentation/screens/chats_screen.dart';
import 'package:vtalk_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vtalk_app/presentation/screens/vpn_screen.dart';

/// HAI3 Organism: Main app shell – Dashboard, Chats, optional AI, optional VPN; flicker-free navigation.
class MainNavShell extends StatefulWidget {
  final int initialIndex;

  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  String _activeTabId = 'chats';
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fixed order of all possible screens
  static const List<String> _allTabIds = ['chats', 'ai', 'vpn', 'dashboard'];
  static const List<Widget> _allScreens = [
    ChatsScreen(key: PageStorageKey<String>('chats')),
    AiAssistantScreen(key: PageStorageKey<String>('ai')),
    VpnScreen(key: PageStorageKey<String>('vpn')),
    DashboardScreen(key: PageStorageKey<String>('dashboard')),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  int _getFixedIndex(String tabId) {
    return _allTabIds.indexOf(tabId);
  }

  void _onTabTapped(String tabId) {
    if (_activeTabId == tabId) return;
    
    final fixedIndex = _getFixedIndex(tabId);
    
    setState(() {
      _activeTabId = tabId;
      _currentIndex = fixedIndex;
    });
  }

  void _handleTabVisibilityChange() {
    final tabVisibility = context.read<TabVisibilityController>();
    
    // Calculate NEW index for current _activeTabId in fixed order
    final newIndex = _getFixedIndex(_activeTabId);
    
    // Update state
    setState(() {
      _currentIndex = newIndex;
    });
    
    // Reset changed flag after processing
    tabVisibility.resetChangedFlag();
  }

  @override
  Widget build(BuildContext context) {
    final tabVisibility = context.watch<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showVpn = tabVisibility.showVpnTab;
    
    // BottomNavigationBar shows only active tabs
    final activeTabs = <_TabItem>[
      const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi) const _TabItem(icon: Icons.psychology_rounded, label: 'AI', id: 'ai'),
      if (showVpn) const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN', id: 'vpn'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', id: 'dashboard'),
    ];

    // Crash protection: safety check
    if (_currentIndex >= _allScreens.length) {
      _currentIndex = 0;
    }

    // Handle tab visibility changes
    if (tabVisibility.hasChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleTabVisibilityChange();
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _currentIndex,
        children: _allScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: activeTabs.indexWhere((tab) => tab.id == _activeTabId),
          onTap: (index) => _onTabTapped(activeTabs[index].id),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: activeTabs
              .map((t) => BottomNavigationBarItem(
                    key: ValueKey(t.id),
                    icon: Icon(t.icon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String id;
  const _TabItem({required this.icon, required this.label, required this.id});
}
