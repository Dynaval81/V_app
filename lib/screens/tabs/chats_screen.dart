import 'package:flutter/material.dart';
import '../../utils/glass_kit.dart';

class ChatsScreen extends StatelessWidget {
  final bool isDark;
  ChatsScreen({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ФИКСИРОВАННАЯ ШАПКА (Интерактивная)
              _buildHeader(context),
              
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // СТАТУСЫ (Уезжают при скролле)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          itemCount: 10,
                          itemBuilder: (context, index) => _statusItem(index),
                        ),
                      ),
                    ),
                    // СПИСОК ЧАТОВ
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _chatTile(index),
                        childCount: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassKit.liquidGlass(
      radius: 0, // На всю ширину сверху
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vtalk", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black), onPressed: () {}),
                CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatTile(int i) {
    return ListTile(
      leading: CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=u$i")),
      title: Text("User $i", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
      subtitle: Text("Encrypted message...", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
      trailing: Text("12:00", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
    );
  }

  Widget _statusItem(int i) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: i == 0 ? Colors.blueAccent : Colors.white10,
            child: CircleAvatar(radius: 27, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$i")),
          ),
          SizedBox(height: 5),
          Text(i == 0 ? "You" : "User $i", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 10)),
        ],
      ),
    );
  }
}