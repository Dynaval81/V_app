import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';

/// HAI3 Organism: Main app shell with bottom nav (Chats | AI Chat | VPN).
class MainNavShell extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const MainNavShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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
          currentIndex: currentIndex.clamp(0, 2),
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_rounded),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.vpn_lock_rounded),
              label: 'VPN',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.chats);
        break;
      case 1:
        context.go(AppRoutes.ai);
        break;
      case 2:
        context.go(AppRoutes.vpn);
        break;
    }
  }
}
