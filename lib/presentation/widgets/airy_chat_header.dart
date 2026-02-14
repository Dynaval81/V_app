import 'package:flutter/material.dart';

class AiryChatHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSearchPressed;
  final VoidCallback onAvatarPressed;

  const AiryChatHeader({
    super.key,
    required this.title,
    required this.onSearchPressed,
    required this.onAvatarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: onSearchPressed,
        ),
        const SizedBox(width: 4),
        GestureDetector( // Using GestureDetector to avoid InkWell padding issues
          onTap: onAvatarPressed,
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=my'),
            ),
          ),
        ),
      ],
    );
  }
}
