import 'package:flutter/material.dart';
import '../models/service_status.dart';
import '../widgets/dashboard_card.dart';
import 'main_app.dart';
import '../constants/app_colors.dart';

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
      backgroundColor: AppColors.primaryBackground,
      body: RefreshIndicator(
        onRefresh: _loadServiceStatuses,
        color: AppColors.primaryBlue,
        backgroundColor: AppColors.cardBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                
                Text(
                  'Welcome to Vtalk!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 10),
                
                Text(
                  'Choose where to start:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                SizedBox(height: 30),
                
                _buildStatusSection(),
                
                SizedBox(height: 30),
                
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          ...(_services.map((service) => _buildStatusRow(service)).toList()),
        ],
      ),
    );
  }

  Widget _buildStatusRow(ServiceStatus service) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: service.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: service.isOnline
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
          
          SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (service.message != null)
                  Text(
                    service.message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: service.isOnline
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              service.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: service.isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF252541),
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
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.white),
              title: Text('Notifications', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.white),
              title: Text('Privacy', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
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