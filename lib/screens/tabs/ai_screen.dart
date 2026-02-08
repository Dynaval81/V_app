import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text('AI Assistant'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.disabledTextColor,
          tabs: [
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
            Tab(text: 'Images', icon: Icon(Icons.image)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildImagesTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildChatMessage(index);
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatMessage(int index) {
    final isUser = index % 2 == 0;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser 
                      ? 'This is a sample user message about AI capabilities'
                      : 'I\'m your AI assistant! I can help you with various tasks. How can I assist you today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '12:3${index} PM',
                    style: TextStyle(
                      color: AppColors.hintTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: AppColors.accentGreen,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.primaryBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: AppColors.hintTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceBackground,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Image Generation',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Create stunning images with AI',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildImageCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.hintTextColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sample Image ${index + 1}',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'AI generated',
                    style: TextStyle(
                      color: AppColors.hintTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}