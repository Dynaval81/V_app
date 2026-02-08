import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  final List<Map<String, String>> mockChats = [
    {"name": "Dmitry", "msg": "Hey, how's the VPN?", "time": "12:40"},
    {"name": "Vtalk AI", "msg": "I can generate that image now.", "time": "11:15"},
    {"name": "Support", "msg": "Your node is active.", "time": "Yesterday"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        title: Text("Messages", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // СТАТУСЫ (Оборачиваем в SizedBox, чтобы не было Overflow)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: 5,
              itemBuilder: (context, index) => _buildStatusCircle(index),
            ),
          ),
          // СПИСОК ЧАТОВ
          Expanded(
            child: ListView.builder(
              itemCount: mockChats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index"),
                  ),
                  title: Text(mockChats[index]['name']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(mockChats[index]['msg']!, style: TextStyle(color: Colors.white54)),
                  trailing: Text(mockChats[index]['time']!, style: TextStyle(color: Colors.white24, fontSize: 12)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(int i) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent,
            child: CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${i + 10}")),
          ),
          SizedBox(height: 4),
          Text("User $i", style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}