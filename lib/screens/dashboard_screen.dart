import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;
  DashboardScreen({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,", 
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                )
              ),
              Text(
                "Dynaval81", 
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 40),
              
              // Кнопки сервисов
              _buildLargeButton(
                context,
                "MESSENGER", 
                "Open secure chats", 
                Icons.chat_bubble, 
                Colors.blue, 
                () => onTabSwitch(0)
              ),
              SizedBox(height: 16),
              _buildLargeButton(
                context,
                "VPN SERVICE", 
                "Connect to secure node", 
                Icons.vpn_lock, 
                Colors.green, 
                () => onTabSwitch(1)
              ),
              SizedBox(height: 16),
              _buildLargeButton(
                context,
                "AI ASSISTANT", 
                "Generate & Edit with AI", 
                Icons.auto_awesome, 
                Colors.purple, 
                () => onTabSwitch(2)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(
                  sub, 
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
                    fontSize: 12
                  )
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios, 
              color: Theme.of(context).iconTheme.color?.withOpacity(0.6), 
              size: 16
            ),
          ],
        ),
      ),
    );
  }
}
