import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 140.0, // Высота, когда всё раскрыто
              title: Text(
                "Vtalk Messenger",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // Аватарка в углу (вместо трех точек)
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18, 
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=me")
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: Column(
                  children: [
                    // Поиск (скрывается при скролле вверх)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, 
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextField(
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                            ),
                            prefixIcon: Icon(
                              Icons.search, 
                              color: Theme.of(context).iconTheme.color?.withOpacity(0.6), 
                              size: 20
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    // Горизонтальные статусы
                    Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildAddStatus(); // Первый кружок - "Добавить"
                          return _buildStatusCircle(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$index")
            ),
            title: Text(
              "User $index", 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            subtitle: Text(
              "How is app going?", 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddStatus() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20, 
            backgroundColor: Colors.blueAccent, 
            child: Icon(Icons.add, color: Colors.white)
          ),
          SizedBox(height: 4),
          Text(
            "My status", 
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), 
              fontSize: 10
            )
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(int i) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.greenAccent, width: 2)
            ),
            child: CircleAvatar(
              radius: 18, 
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${i+10}")
            ),
          ),
          SizedBox(height: 4),
          Text(
            "User $i", 
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), 
              fontSize: 10
            )
          ),
        ],
      ),
    );
  }
}