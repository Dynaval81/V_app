import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:vtalk_app/presentation/screens/chats_screen.dart';
import 'package:vtalk_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vtalk_app/presentation/screens/vpn_screen.dart';

/// HAI3 Organism: Main app shell – Dashboard, Chats, optional AI, optional VPN; swipeable PageView.
class MainNavShell extends StatefulWidget {
  final int initialIndex;

  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late PageController _pageController;
  late int _currentIndex;

  int? _lastTabsHash;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _currentIndex = 0;
  }

  int _tabsHash(bool showAi, bool showVpn) {
    return (showAi ? 1 : 0) | (showVpn ? 2 : 0);
  }

  int _currentTabId(bool showAi, bool showVpn) {
    if (_currentIndex == 0) return 0; // chats
    if (showAi && _currentIndex == 1) return 1; // ai
    if (showVpn && _currentIndex == (showAi ? 2 : 1)) return 2; // vpn
    return 3; // dashboard
  }

  int _indexFromTabId(int tabId, bool showAi, bool showVpn) {
    switch (tabId) {
      case 0:
        return 0;
      case 1:
        return showAi ? 1 : 0;
      case 2:
        if (!showVpn) return showAi ? 1 : 0;
        return showAi ? 2 : 1;
      case 3:
      default:
        return (1 + (showAi ? 1 : 0) + (showVpn ? 1 : 0));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabVisibility = context.watch<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showVpn = tabVisibility.showVpnTab;
    final tabs = <_TabItem>[
      const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
      if (showAi) const _TabItem(icon: Icons.psychology_rounded, label: 'AI'),
      if (showVpn) const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    ];
    final pages = <Widget>[
      const ChatsScreen(),
      if (showAi) const AiAssistantScreen(),
      if (showVpn) const VpnScreen(),
      const DashboardScreen(),
    ];

    final hash = _tabsHash(showAi, showVpn);
    var newIndex = _currentIndex;
    if (_lastTabsHash != null && _lastTabsHash != hash) {
      final tabId = _currentTabId(showAi, showVpn);
      newIndex = _indexFromTabId(tabId, showAi, showVpn);
    } else if (_currentIndex >= pages.length) {
      newIndex = pages.length - 1;
    }

    if (newIndex != _currentIndex || _lastTabsHash != hash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _lastTabsHash = hash;
        if (_currentIndex != newIndex) {
          setState(() => _currentIndex = newIndex);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(newIndex);
          }
        } else {
          _lastTabsHash = hash;
        }
      });
    }
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        physics: const BouncingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: newIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: tabs
              .map((t) => BottomNavigationBarItem(
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
  const _TabItem({required this.icon, required this.label});
}
