import 'package:flutter/material.dart';
import '../utils/glass_kit.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  final bool isDark;
  final Function(int) onTabSwitch;
  final Function(bool) onThemeToggle;

  DashboardScreen({
    required this.isDark,
    required this.onTabSwitch,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                    _glassBtn("MESSENGER", Icons.chat_bubble_outline, Colors.blueAccent, () => onTabSwitch(1)),
                    _glassBtn("VPN SERVICE", Icons.vpn_lock, Colors.greenAccent, () => onTabSwitch(2)),
                    _glassBtn("AI ASSISTANT", Icons.auto_awesome, Colors.purpleAccent, () => onTabSwitch(3)),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              isDark: isDark,
                              onThemeToggle: onThemeToggle,
                            ),
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
  }

  Widget _buildAppBar(String title) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
          CircleAvatar(radius: 22, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")),
        ],
      ),
    );
  }

  Widget _glassBtn(String t, IconData i, Color c, VoidCallback a) {
    return ListTile(
      onTap: a,
      leading: Icon(i, color: c, size: 28),
      title: Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      trailing: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white10 : Colors.black12, size: 16),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }
}
