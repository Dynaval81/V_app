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
          child: CustomScrollView(
            slivers: [
              // ЗАКРЕПЛЕННАЯ ШАПКА
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true, 
                expandedHeight: 70,
                elevation: 0,
                flexibleSpace: GlassKit.liquidGlass( // Шапка тоже стеклянная
                  radius: 0,
                  child: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                    title: Text("Vtalk", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                actions: [
                  IconButton(icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black), onPressed: () {}),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")),
                  ),
                ],
              ),

              // ПОИСК (теперь он тут)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: GlassKit.liquidGlass(
                    radius: 12,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search messages...",
                        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // СТАТУСЫ (уезжают)
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) => _statusItem(index, isDark),
                  ),
                ),
              ),

              // СПИСОК ЧАТОВ (без боксов, просто список)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index")),
                        title: Text("User $index", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        subtitle: Text("Latest message text here...", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                        trailing: Text("12:00", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
                      ),
                      Divider(color: Colors.white.withOpacity(0.05), indent: 70), // Тонкая линия вместо бокса
                    ],
                  ),
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusItem(int i, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: i == 0 ? Colors.blue : Colors.greenAccent.withOpacity(0.5),
            child: CircleAvatar(radius: 27, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=s$i")),
          ),
          SizedBox(height: 5),
          Text(i == 0 ? "You" : "User $i", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 10)),
        ],
      ),
    );
  }
}