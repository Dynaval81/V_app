import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/dashboard_card.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryText),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildChatItem(index);
        },
      ),
    );
  }

  Widget _buildChatItem(int index) {
    final names = ['Alice Johnson', 'Bob Smith', 'Carol White', 'David Brown', 'Emma Davis'];
    final messages = [
      'Hey! How are you doing?',
      'Can we schedule a call?',
      'Thanks for your help!',
      'See you tomorrow!',
      'Great news! 🎉'
    ];
    final times = ['2 min ago', '15 min ago', '1 hour ago', '3 hours ago', 'Yesterday'];
    
    return DashboardCard(
      icon: '💬',
      title: names[index],
      description: messages[index],
      color: AppColors.primaryBlue,
      onTap: () {
        // TODO: Navigate to chat screen
      },
    );
  }
}