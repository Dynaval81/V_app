import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class VtalkHeader extends StatefulWidget {
  final String title;
  final bool showScrollAnimation;
  final List<Widget>? actions;
  final double? scrollOffset;
  
  const VtalkHeader({
    required this.title,
    this.showScrollAnimation = true,
    this.actions,
    this.scrollOffset,
  });

  @override
  _VtalkHeaderState createState() => _VtalkHeaderState();
}

class _VtalkHeaderState extends State<VtalkHeader>
  with TickerProviderStateMixin {
  late AnimationController _avatarController;
  late AnimationController _titleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0, 
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _avatarController, 
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _avatarController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  
  void _animateAvatar() {
    HapticFeedback.lightImpact();
    _avatarController.forward().then((_) {
      _avatarController.reverse();
    });
  }
  
  double _calculateTitleOpacity() {
    if (!widget.showScrollAnimation || widget.scrollOffset == null) {
      return 1.0;
    }
    
    // Заголовок начинает исчезать при скролле > 50px
    final fadeStart = 50.0;
    final fadeEnd = 150.0;
    
    if (widget.scrollOffset! <= fadeStart) {
      return 1.0;
    } else if (widget.scrollOffset! >= fadeEnd) {
      return 0.0;
    } else {
      return 1.0 - ((widget.scrollOffset! - fadeStart) / (fadeEnd - fadeStart));
    }
  }
  
  double _calculateAppBarOpacity() {
    if (!widget.showScrollAnimation || widget.scrollOffset == null) {
      return 0.0;
    }
    
    // Фон появляется при скролле > 100px
    final fadeStart = 100.0;
    final fadeEnd = 200.0;
    
    if (widget.scrollOffset! <= fadeStart) {
      return 0.0;
    } else if (widget.scrollOffset! >= fadeEnd) {
      return 0.4;
    } else {
      return ((widget.scrollOffset! - fadeStart) / (fadeEnd - fadeStart)) * 0.4;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // 🚨 НОВОЕ: Синхронизируем цвета с BottomNavigationBar
    final Color activeColor = Theme.of(context).primaryColor; // Голубой
    final Color inactiveColor = isDark ? Colors.grey : Colors.black54;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: GlassKit.liquidGlass(
        radius: 0,
        isDark: isDark,
        opacity: appBarOpacity,
        useBlur: true,  // ✅ Явно включаем блюр для заголовка
        child: Container(),
      ),
      title: Row(
        children: [
          // 🚨 НОВОЕ: LOGO с адаптивным цветом
          Image.asset(
            'assets/images/app_logo_classic.png',
            height: 30,
            color: isDark ? Colors.white : activeColor, // 🚨 Теперь не сливается!
          ),
          const SizedBox(width: 8),
          // 🚨 НОВОЕ: Заголовок в тон меню
          Text(
            "V-TALK",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: activeColor, // 🚨 Голубой как внизу
            ),
          ),
          const Spacer(),
          // 🚨 НОВОЕ: Аватарка с плашкой FREE
          Stack(
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me"),
                  );
                },
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (!userProvider.isPremium) {
                    return Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                        child: const Text("FREE", style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      actions: widget.actions ?? [],
      // ✅ Заменили небезопасное распаковывание на безопасное
      bottom: widget.showScrollAnimation
          ? PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTapDown: (_) => _animateAvatar(),
                    onTapUp: (_) => _avatarController.reverse(),
                    onTapCancel: () => _avatarController.reverse(),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.withOpacity(0.7),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
