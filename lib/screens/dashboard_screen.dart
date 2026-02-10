import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../utils/glass_kit.dart';
import '../widgets/vtalk_unified_app_bar.dart';
import './account_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabSwitch;
  
  const DashboardScreen({super.key, required this.onTabSwitch});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: GlassKit.liquidGlass(
        radius: 16,
        isDark: isDark,
        opacity: 0.08,
        useBlur: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassKit.liquidGlass(
          radius: 16,
          isDark: isDark,
          opacity: 0.06,
          useBlur: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
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
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle, 
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded, 
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: VtalkUnifiedAppBar(
        title: 'Dashboard',
        isDark: isDark,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
        ),
      ),
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // ✨ Enhanced Header - Removed (now using appBar)
              const SizedBox(height: 12),

              // 📊 Stats Row
              Row(
                children: [
                  _buildStatCard(
                    label: 'Chats',
                    value: '24',
                    icon: Icons.chat_bubble_outline,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    label: 'Online',
                    value: '12',
                    icon: Icons.person_add,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    label: 'Storage',
                    value: '2.4GB',
                    icon: Icons.storage,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 🔐 Status Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              GlassKit.liquidGlass(
                radius: 16,
                isDark: isDark,
                opacity: 0.08,
                useBlur: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VPN Connection',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Connected • Moscow, RU',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 🎯 Quick Actions
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildAirItem(
                icon: Icons.vpn_lock_rounded,
                title: 'Vtalk VPN',
                subtitle: 'Secure & Anonymous Connection',
                color: Colors.blue,
                isDark: isDark,
                onTap: () => widget.onTabSwitch(1),
              ),

              _buildAirItem(
                icon: Icons.psychology_rounded,
                title: 'AI Assistant',
                subtitle: 'Smart conversations & help',
                color: Colors.purple,
                isDark: isDark,
                onTap: () => widget.onTabSwitch(2),
              ),

              _buildAirItem(
                icon: Icons.message_rounded,
                title: 'Chats',
                subtitle: 'Back to your conversations',
                color: Colors.cyan,
                isDark: isDark,
                onTap: () => widget.onTabSwitch(0),
              ),

              const SizedBox(height: 32),

              // ℹ️ About Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'App Info',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildAirItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQ and contact information',
                color: Colors.orange,
                isDark: isDark,
                onTap: () => _showAboutDialog(context, isDark),
              ),

              _buildAirItem(
                icon: Icons.info_outline,
                title: 'About Vtalk',
                subtitle: 'Version 0.5 • Mercury Edition',
                color: Colors.teal,
                isDark: isDark,
                onTap: () => _showAboutDialog(context, isDark),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassKit.liquidGlass(
          radius: 24,
          isDark: isDark,
          opacity: 0.15,
          useBlur: true,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'About Vtalk',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white60 : Colors.black45,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VTalk v0.5 • Mercury Edition',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A modern messaging app with emoji support, VPN integration, and AI-powered features.',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black45,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '✨ Features',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                    '✅ Emoji System with GIF Support',
                    '✅ VPN Integration',
                    '✅ AI Assistant',
                    '✅ Dark/Light Theme',
                    '✅ Mercury Design System',
                    '✅ Real-time Messaging',
                  ].map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: GlassKit.liquidGlass(
                            radius: 12,
                            isDark: isDark,
                            opacity: 0.15,
                            useBlur: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
