import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch; // Это передается из MainApp
  DashboardScreen({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text("Dynaval81", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Vtalk Control Panel", style: TextStyle(color: Colors.white54)),
              SizedBox(height: 40),

              // Кнопки теперь ОБЯЗАНЫ работать
              _buildBtn("MESSENGER", Icons.chat_bubble, Colors.blue, () => onTabSwitch(1)),
              _buildBtn("VPN SERVICE", Icons.vpn_lock, Colors.green, () => onTabSwitch(2)),
              _buildBtn("AI ASSISTANT", Icons.auto_awesome, Colors.purple, () => onTabSwitch(3)),
              
              Spacer(), // Прижимает настройки к низу
              
              _buildBtn("SETTINGS", Icons.settings, Colors.orange, () {
                // Здесь логика перехода в настройки (например, Navigator.push)
                print("Settings clicked");
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(String title, IconData icon, Color color, VoidCallback action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: action, // Тот самый вызов переключения
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF252541),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(width: 20),
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
