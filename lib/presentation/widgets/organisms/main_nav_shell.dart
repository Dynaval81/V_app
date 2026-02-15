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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _currentIndex = 0;
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
    final tabs = <_TabItem>[
      const _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
      if (tabVisibility.showAiTab) const _TabItem(icon: Icons.psychology_rounded, label: 'AI'),
      if (tabVisibility.showVpnTab) const _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN'),
      const _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    ];
    final pages = <Widget>[
      const ChatsScreen(),
      if (tabVisibility.showAiTab) const AiAssistantScreen(),
      if (tabVisibility.showVpnTab) const VpnScreen(),
      const DashboardScreen(),
    ];
    
    // Preserve current index when tabs visibility changes
    final newIndex = _currentIndex < pages.length ? _currentIndex : pages.length - 1;
    if (newIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = newIndex);
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
