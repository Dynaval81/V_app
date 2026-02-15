import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/constants/app_colors.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:vtalk_app/presentation/screens/chats_screen.dart';
import 'package:vtalk_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vtalk_app/presentation/screens/vpn_screen.dart';

/// HAI3 Organism: Main app shell – Dashboard, Chats, optional AI, optional VPN; rock-solid navigation.
class MainNavShell extends StatefulWidget {
  final int initialIndex;

  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late PageController _pageController;
  String _activeTabId = 'chats';
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _currentIndex = 0;
  }

  @override
  void dispose() {
    if (_pageController.hasClients) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(String tabId) {
    if (_activeTabId == tabId) return;
    
    final newIndex = _getIndexOfId(tabId);
    
    setState(() {
      _activeTabId = tabId;
      _currentIndex = newIndex;
    });
    
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentIndex);
    }
  }

  int _getIndexOfId(String tabId) {
    final tabVisibility = context.read<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showVpn = tabVisibility.showVpnTab;
    
    switch (tabId) {
      case 'chats':
        return 0;
      case 'ai':
        return showAi ? 1 : 0;
      case 'vpn':
        return (showAi ? 1 : 0) + (showVpn ? 1 : 0);
      case 'dashboard':
      default:
        return (1 + (showAi ? 1 : 0) + (showVpn ? 1 : 0));
    }
  }

  void _handleTabVisibilityChange() {
    final tabVisibility = context.read<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showVpn = tabVisibility.showVpnTab;
    
    // Calculate new tabs list
    final newTabs = <_TabItem>[
      const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi) const _TabItem(icon: Icons.psychology_rounded, label: 'AI', id: 'ai'),
      if (showVpn) const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN', id: 'vpn'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', id: 'dashboard'),
    ];

    // Calculate NEW index for current _activeTabId in FUTURE tabs list
    final newIndex = _getIndexOfId(_activeTabId);
    
    // First jump to correct position
    if (_pageController.hasClients) {
      _pageController.jumpToPage(newIndex);
    }
    
    // Then update state
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
    
    final tabs = <_TabItem>[
      const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats', id: 'chats'),
      if (showAi) const _TabItem(icon: Icons.psychology_rounded, label: 'AI', id: 'ai'),
      if (showVpn) const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN', id: 'vpn'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard', id: 'dashboard'),
    ];
    
    // Crash protection: safety check
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }
    
    final pages = <Widget>[
      const ChatsScreen(
        key: PageStorageKey<String>('chats'),
      ),
      if (showAi) const AiAssistantScreen(
        key: PageStorageKey<String>('ai'),
      ),
      if (showVpn) const VpnScreen(
        key: PageStorageKey<String>('vpn'),
      ),
      const DashboardScreen(
        key: PageStorageKey<String>('dashboard'),
      ),
    ];

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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // Update active tab based on current page index
          String newTabId = 'chats';
          if (index == 0) {
            newTabId = 'chats';
          } else if (showAi && index == 1) {
            newTabId = 'ai';
          } else if (showVpn && index == (showAi ? 2 : 1)) {
            newTabId = 'vpn';
          } else {
            newTabId = 'dashboard';
          }
          
          if (newTabId != _activeTabId) {
            setState(() => _activeTabId = newTabId);
          }
        },
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
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
          currentIndex: _currentIndex,
          onTap: (index) => _onTabTapped(tabs[index].id),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: tabs
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
