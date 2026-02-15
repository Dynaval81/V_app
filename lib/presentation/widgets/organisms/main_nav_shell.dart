import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:vtalk_app/presentation/screens/chats_screen.dart';
import 'package:vtalk_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vtalk_app/presentation/screens/vpn_screen.dart';

/// HAI3 Organism: Main app shell – 4 tabs (Dashboard, Chats, AI, VPN), swipeable PageView, profile → Settings.
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
    _pageController = PageController(initialPage: widget.initialIndex.clamp(0, 3));
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  void didUpdateWidget(MainNavShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex >= 0 &&
        widget.initialIndex <= 3) {
      _currentIndex = widget.initialIndex;
      _pageController.jumpToPage(widget.initialIndex);
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

  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _TabItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
    _TabItem(icon: Icons.psychology_rounded, label: 'AI'),
    _TabItem(icon: Icons.vpn_lock_rounded, label: 'VPN'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        physics: const BouncingScrollPhysics(),
        children: const [
          DashboardScreen(),
          ChatsScreen(),
          AiAssistantScreen(),
          VpnScreen(),
        ],
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
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: _tabs
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
