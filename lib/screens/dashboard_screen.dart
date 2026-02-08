import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_status.dart';
import '../widgets/dashboard_card.dart';
import 'main_app.dart';
import 'auth/register_screen.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ServiceStatus> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServiceStatuses();
  }

  Future<void> _loadServiceStatuses() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _services = [
        ServiceStatus(
          name: 'Messenger',
          isOnline: true,
          status: 'online',
          message: 'All systems operational',
        ),
        ServiceStatus(
          name: 'VPN',
          isOnline: true,
          status: 'online',
          message: '3 servers available',
        ),
        ServiceStatus(
          name: 'AI Chat',
          isOnline: false,
          status: 'offline',
          message: 'Coming soon',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadServiceStatuses,
        color: Colors.blue,
        backgroundColor: Theme.of(context).cardColor,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                
                _buildStatusSection(),
                
                SizedBox(height: 30),
                
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                
                SizedBox(height: 16),
                
                DashboardCard(
                  icon: '💬',
                  title: 'Messenger',
                  description: 'Secure private chats',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainApp(initialTab: 0),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                DashboardCard(
                  icon: '🔐',
                  title: 'VPN',
                  description: 'Browse anonymously',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainApp(initialTab: 1),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                DashboardCard(
                  icon: '🤖',
                  title: 'AI Chat',
                  description: 'Talk with AI assistant',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainApp(initialTab: 2),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 16),
                
                DashboardCard(
                  icon: '⚙️',
                  title: 'Settings',
                  description: 'Manage your account',
                  color: Colors.grey,
                  onTap: () {
                    _showSettingsBottomSheet(context);
                  },
                ),
                
                SizedBox(height: 16),
                
                DashboardCard(
                  icon: '⭐',
                  title: 'Premium',
                  description: 'Unlock all features',
                  color: Colors.amber,
                  onTap: () {
                    _showPremiumDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            icon: Icons.message,
            label: 'Messenger',
            isOnline: _services.isNotEmpty ? _services[0].isOnline : false,
          ),
          _buildStatusItem(
            icon: Icons.vpn_lock,
            label: 'VPN',
            isOnline: _services.length > 1 ? _services[1].isOnline : false,
          ),
          _buildStatusItem(
            icon: Icons.smart_toy,
            label: 'AI Chat',
            isOnline: _services.length > 2 ? _services[2].isOnline : false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({required IconData icon, required String label, required bool isOnline}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOnline ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isOnline ? Colors.green : Colors.grey,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 20),
          
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Profile',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            onTap: () {},
          ),
          
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Notifications',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            onTap: () {},
          ),
          
          // ⭐ ПЕРЕКЛЮЧАТЕЛЬ ТЕМЫ
          ListTile(
            leading: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              'Theme',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
                Navigator.pop(context); // Закрыть Bottom Sheet
              },
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).iconTheme.color),
            title: Text(
              'Privacy',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            onTap: () {},
          ),
          
          SizedBox(height: 20),
          
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                Navigator.pop(context); // Закрыть Bottom Sheet
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                  (route) => false, // Удалить весь стек навигации
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF252541),
        title: Text(
          '⭐ Premium',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Coming soon!\n\nUnlock unlimited VPN bandwidth, AI features, and more.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
