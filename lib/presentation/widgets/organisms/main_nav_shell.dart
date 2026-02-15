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
  String _currentTabId = 'chats';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ID-based navigation map
  final Map<String, int> _tabMap = {
    'chats': 0,
    'ai': 1,
    'vpn': 2,
    'dashboard': 3,
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    if (_pageController.hasClients) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(String tabId) {
    if (_currentTabId == tabId) return;
    
    setState(() => _currentTabId = tabId);
    
    final newIndex = _getTabIndex(tabId);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  int _getTabIndex(String tabId) {
    final tabVisibility = context.read<TabVisibilityController>();
    final showAi = tabVisibility.showAiTab;
    final showVpn = tabVisibility.showVpnTab;
    
    int index = 0;
    
    // Always have chats first
    if (tabId == 'chats') return 0;
    index++;
    
    // Add AI if visible
    if (showAi) {
      if (tabId == 'ai') return index;
      index++;
    }
    
    // Add VPN if visible
    if (showVpn) {
      if (tabId == 'vpn') return index;
      index++;
    }
    
    // Dashboard is always last
    if (tabId == 'dashboard') return index;
    
    return 0; // fallback to chats
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
    
    final pages = <Widget>[
      const ChatsScreen(),
      if (showAi) const AiAssistantScreen(),
      if (showVpn) const VpnScreen(),
      const DashboardScreen(),
    ];

    // Update current index when tabs change
    final newIndex = _getTabIndex(_currentTabId);
    if (_pageController.hasClients && _pageController.page?.round() != newIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(newIndex);
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // Update current tab ID based on page index
          final activeTabs = <String>['chats'];
          if (showAi) activeTabs.add('ai');
          if (showVpn) activeTabs.add('vpn');
          activeTabs.add('dashboard');
          
          if (index < activeTabs.length) {
            setState(() => _currentTabId = activeTabs[index]);
          }
        },
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
          onTap: (index) => _onTabTapped(tabs[index].id),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
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
