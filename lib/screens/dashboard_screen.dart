import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;

  DashboardScreen({
    required this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: GlassKit.mainBackground(isDark),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar("Vtalk Console"),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [
                        _glassBtn("MESSENGER", Icons.chat_bubble_outline, Colors.blueAccent, () => onTabSwitch(0)),
                        _glassBtn("VPN SERVICE", Icons.vpn_lock, Colors.greenAccent, () => onTabSwitch(1)),
                        _glassBtn("AI ASSISTANT", Icons.auto_awesome, Colors.purpleAccent, () => onTabSwitch(2)),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(),
                              ),
                            );
                          },
                          leading: Icon(Icons.settings_suggest, color: Colors.orangeAccent, size: 28),
                          title: Text("SETTINGS", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                          trailing: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white10 : Colors.black12, size: 16),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(String title) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              Icon(Icons.settings_suggest, color: Colors.orangeAccent, size: 28),
            ],
          ),
        );
      },
    );
  }

  Widget _glassBtn(String t, IconData i, Color c, VoidCallback a) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return ListTile(
          onTap: a,
          leading: Icon(i, color: c, size: 28),
          title: Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          trailing: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white10 : Colors.black12, size: 16),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        );
      },
    );
  }
}
