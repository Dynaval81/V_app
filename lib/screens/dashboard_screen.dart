import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;
  DashboardScreen({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar( // Своя шапка в стиле мессенджера
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        title: Text("Vtalk Console", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined), 
            onPressed: () => onTabSwitch(3) // Например, переброс на AI или экран настроек
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMenuCard("MESSENGER", Icons.chat_bubble, Colors.blue, () => onTabSwitch(1)),
            SizedBox(height: 15),
            _buildMenuCard("VPN SERVICE", Icons.security, Colors.green, () => onTabSwitch(2)),
            SizedBox(height: 15),
            _buildMenuCard("AI STUDIO", Icons.auto_awesome, Colors.purple, () => onTabSwitch(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF252541),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(width: 20),
            Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
