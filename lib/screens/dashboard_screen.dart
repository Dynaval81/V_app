import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import '../widgets/vtalk_header.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;
  
  const DashboardScreen({super.key, required this.onTabSwitch});

  Widget _buildAirItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right_rounded, 
          color: isDark ? Colors.white30 : Colors.black12,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVPNIndicator(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'VPN Status',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                'Connected',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Пульсирующая линия
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.6),
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.6),
                ],
              ),
            ),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassKit.mainBackground(isDark: isDark),
      body: CustomScrollView(
        slivers: [
          VtalkHeader(
            title: 'VTALK',
            showScrollAnimation: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: 1,
                builder: (context, index) {
                  return Column(
                    children: [
                      _buildVPNIndicator(isDark),
                      const SizedBox(height: 32),
                      _buildAirItem(
                        icon: Icons.security,
                        title: 'Privacy & Security',
                        subtitle: 'Encryption, permissions, data protection',
                        color: Colors.blue,
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _buildAirItem(
                        icon: Icons.notifications_active,
                        title: 'Notifications',
                        subtitle: 'Sounds, badges, Do Not Disturb',
                        color: Colors.purple,
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _buildAirItem(
                        icon: Icons.storage,
                        title: 'Storage & Data',
                        subtitle: 'Cache, downloads, backup',
                        color: Colors.orange,
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _buildAirItem(
                        icon: Icons.palette,
                        title: 'Appearance',
                        subtitle: 'Themes, fonts, display settings',
                        color: Colors.pink,
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _buildAirItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'FAQ, contact, about',
                        color: Colors.cyan,
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _buildAirItem(
                        icon: Icons.info_outline,
                        title: 'About Vtalk',
                        subtitle: 'Version 0.5, licenses, credits',
                        color: Colors.teal,
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ];
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Вспомогательный виджет для анимации
class AnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final BoxDecoration decoration;
  
  const AnimatedContainer({
    super.key,
    required this.child,
    required this.duration,
    required this.decoration,
  });

  @override
  State<AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: widget.decoration,
          child: child,
        );
      },
    );
  }
}
