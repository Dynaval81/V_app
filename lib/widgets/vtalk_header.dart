import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';
import 'package:provider/provider.dart';

class VtalkHeader extends StatelessWidget {
  final String title;
  final bool showScrollAnimation;
  final List<Widget>? actions;
  
  const VtalkHeader({
    required this.title,
    this.showScrollAnimation = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = const Color(0xFF00B2FF); // 🚨 Голубая ртуть

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🚨 Эффект стекла
        child: Container(
          height: 70, // 🚨 Фиксированная высота
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
            border: Border(bottom: BorderSide(color: accentColor.withOpacity(0.2), width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🚨 ЛОГОТИП: BoxFit.contain чтобы не раскорячило
                Image.asset(
                  'assets/images/app_logo_classic.png',
                  height: 28,
                  fit: BoxFit.contain,
                  color: isDark ? Colors.white : accentColor,
                ),
                Text(
                  "V-TALK",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.2),
                ),
                // 🚨 АВАТАР: Один, с плашкой FREE
                GestureDetector(
                  onTap: () => _openAccountMenu(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return CircleAvatar(
                            radius: 18, 
                            backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me")
                          );
                        },
                      ),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          if (!userProvider.isPremium) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green, 
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: const Text(
                                "FREE", 
                                style: TextStyle(
                                  fontSize: 7, 
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAccountMenu(BuildContext context) {
    // 🚨 Открываем боковое меню вместо диалога
    Scaffold.of(context).openDrawer();
  }
}
