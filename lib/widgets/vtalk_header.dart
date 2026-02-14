import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';
import 'package:provider/provider.dart';

class VtalkHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showScrollAnimation;
  final List<Widget>? actions;
  
  const VtalkHeader({
    required this.title,
    this.showScrollAnimation = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = const Color(0xFF00B2FF); // 🚨 Тот самый голубой "Ртуть"

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 🚨 Эффект стекла
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            border: Border(bottom: BorderSide(color: accentColor.withOpacity(0.3))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🚨 LOGO с фильтром цвета
                Image.asset(
                  'assets/images/app_logo_classic.png',
                  height: 28,
                  color: isDark ? Colors.white : accentColor, 
                ),
                Text(
                  "V-TALK",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, 
                    color: accentColor // 🚨 Голубой как внизу
                  ),
                ),
                // 🚨 Единственная аватарка с плашкой FREE
                GestureDetector(
                  onTap: () => _showPremiumDialog(context),
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

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("V-Talk Premium"),
        content: const Text("Enter your activation code or upgrade to unlock all features."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {}, 
            child: const Text("Upgrade")
          ),
        ],
      ),
    );
  }
}
