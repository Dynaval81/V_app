import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabSwitch;
  DashboardScreen({required this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      border: Border.all(color: Colors.blueAccent, width: 2)
                    ),
                    child: CircleAvatar(
                      radius: 25, 
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=my_id")
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Admin", 
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
                          fontSize: 12
                        )
                      ),
                      Text(
                        "Dynaval81", 
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                  Spacer(),
                  _statusBadge(true), // Индикатор статуса всей системы
                ],
              ),
              
              SizedBox(height: 30),

              // GRID OF SERVICES
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildServiceItem(context, "Messenger", Icons.chat_bubble_outline, Colors.blue, 1),
                  _buildServiceItem(context, "Secure VPN", Icons.vpn_lock, Colors.greenAccent, 2),
                  _buildServiceItem(context, "AI Studio", Icons.auto_awesome, Colors.purpleAccent, 3),
                  _buildServiceItem(context, "System Logs", Icons.terminal, Colors.orangeAccent, 0),
                ],
              ),

              SizedBox(height: 30),
              Text(
                "Performance", 
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 15),

              // ЗАГЛУШКА ДЛЯ ГРАФИКА
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Icon(
                    Icons.insights, 
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3), 
                    size: 50
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool online) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: online 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          Container(
            width: 8, 
            height: 8, 
            decoration: BoxDecoration(
              color: online ? Colors.green : Colors.red, 
              shape: BoxShape.circle
            )
          ),
          SizedBox(width: 8),
          Text(
            online ? "SYSTEM OK" : "ISSUES", 
            style: TextStyle(
              color: online ? Colors.green : Colors.red, 
              fontSize: 10, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String title, IconData icon, Color color, int tabIndex) {
    return InkWell(
      onTap: () => onTabSwitch(tabIndex),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            SizedBox(height: 12),
            Text(
              title, 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color, 
                fontWeight: FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }
}
