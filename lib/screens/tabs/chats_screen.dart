import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text(
          'Chats',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryText),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.primaryText),
            color: AppColors.cardBackground,
            itemBuilder: (BuildContext context) {
              return {'Settings', 'Invite'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: TextStyle(color: AppColors.primaryText)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildChatItem(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(int index) {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Carol White', 'David Brown', 'Emma Davis',
      'Frank Miller', 'Grace Wilson', 'Henry Taylor', 'Iris Anderson', 'Jack Thomas'
    ];
    final messages = [
      'Hey! How are you doing?',
      'Can we schedule a call?',
      'Thanks for your help!',
      'See you tomorrow!',
      'Great news! 🎉',
      'Meeting at 3pm',
      'Check this out!',
      'Did you see the game?',
      'Happy birthday! 🎂',
      'Let\'s catch up soon'
    ];
    final times = [
      '2 min ago', '15 min ago', '1 hour ago', '3 hours ago', 'Yesterday',
      '2 days ago', '3 days ago', '1 week ago', '2 weeks ago', '1 month ago'
    ];
    final isUnread = index < 3;
    final hasAvatar = index % 2 == 0;
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: hasAvatar 
          ? AppColors.primaryBlue.withOpacity(0.2)
          : AppColors.accentGreen.withOpacity(0.2),
        child: hasAvatar
          ? Icon(Icons.person, color: AppColors.primaryBlue, size: 28)
          : Text(
              names[index][0].toUpperCase(),
              style: TextStyle(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      ),
      title: Text(
        names[index],
        style: TextStyle(
          color: AppColors.primaryText,
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        messages[index],
        style: TextStyle(
          color: AppColors.secondaryText,
          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            times[index],
            style: TextStyle(
              color: isUnread ? AppColors.primaryBlue : AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          if (isUnread) ...[
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${(index % 5) + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        // TODO: Navigate to chat screen
      },
    );
  }
}