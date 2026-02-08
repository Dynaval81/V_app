import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        title: Text("Vtalk", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск (на всю ширину)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: Color(0xFF252541), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  hintStyle: TextStyle(color: Colors.white24),
                  prefixIcon: Icon(Icons.search, color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // СТАТУСЫ (Без Overflow)
          Container(
            height: 95, // Фиксированная высота, чтобы не плыло
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: index == 0 ? Colors.blueAccent : Colors.greenAccent,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index"),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Contact $index", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),

          // СПИСОК ЧАТОВ
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${index + 50}"),
                  ),
                  title: Text("Alice Smith", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Hey! Did you check new VPN?", style: TextStyle(color: Colors.white54)),
                  trailing: Text("14:20", style: TextStyle(color: Colors.white24, fontSize: 12)),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}