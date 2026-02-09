import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;
  
  const DashboardScreen({super.key, required this.onTabSwitch});

  Widget _buildSettingItem({
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
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.6),
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.6),
                ],
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [Colors.black87, Colors.black54, Colors.black26]
                : [Colors.white, Colors.white70, Colors.white30],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              floating: true,
              title: Text(
                'VTALK',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    // TODO: Add settings
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      children: [
                        _buildVPNIndicator(isDark),
                        const SizedBox(height: 32),
                        _buildSettingItem(
                          icon: Icons.security,
                          title: 'Privacy & Security',
                          subtitle: 'Encryption, permissions, data protection',
                          color: Colors.blue,
                          isDark: isDark,
                          onTap: () {
                            // TODO: Add privacy settings
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.notifications_active,
                          title: 'Notifications',
                          subtitle: 'Sounds, badges, Do Not Disturb',
                          color: Colors.purple,
                          isDark: isDark,
                          onTap: () {
                            // TODO: Add notification settings
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.storage,
                          title: 'Storage & Data',
                          subtitle: 'Cache, downloads, backup',
                          color: Colors.orange,
                          isDark: isDark,
                          onTap: () {
                            // TODO: Add storage settings
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.palette,
                          title: 'Appearance',
                          subtitle: 'Themes, fonts, display settings',
                          color: Colors.pink,
                          isDark: isDark,
                          onTap: () {
                            // Toggle theme
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'FAQ, contact, about',
                          color: Colors.cyan,
                          isDark: isDark,
                          onTap: () {
                            // TODO: Add help
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: 'About Vtalk',
                          subtitle: 'Version 0.5, licenses, credits',
                          color: Colors.teal,
                          isDark: isDark,
                          onTap: () {
                            _showAboutDialog(context, isDark);
                          },
                        ),
                      ],
                    );
                  },
                  childCount: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: Text(
          'About Vtalk',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VTalk v0.5: Mercury',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A modern messaging app with emoji support, VPN integration, and AI-powered features.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...[
              '✅ Emoji System',
              '✅ VPN Integration',
              '✅ AI Assistant',
              '✅ Dark/Light Theme',
              '✅ Native Navigation',
            ].map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                feature,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
