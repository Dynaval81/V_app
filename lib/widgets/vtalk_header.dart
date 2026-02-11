import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/glass_kit.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';

class VtalkHeader extends StatefulWidget {
  final String title;
  final bool showScrollAnimation;
  final List<Widget>? actions;
  final ScrollController? scrollController; // Добавляем ScrollController
  
  const VtalkHeader({
    required this.title,
    this.showScrollAnimation = true,
    this.actions,
    this.scrollController, // Опциональный контроллер
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
  
  // Безопасные геттеры для расчета значений
  double get _currentDensity {
    try {
      // Проверяем: прикреплен ли контроллер и есть ли у него размеры
      if (widget.scrollController != null && widget.scrollController!.hasClients) {
        return (widget.scrollController!.offset / 100).clamp(0.0, 0.8);
      }
    } catch (_) {
      // Если что-то пошло не так (например, во время dispose)
    }
    return 0.0; // По умолчанию шапка прозрачная
  }

  double get _currentOpacity {
    try {
      if (widget.scrollController != null && widget.scrollController!.hasClients) {
        // Текст исчезает быстрее, чем появляется блюр шапки
        return (1.0 - (widget.scrollController!.offset / 60)).clamp(0.0, 1.0);
      }
    } catch (_) {}
    return 1.0; // По умолчанию текст виден полностью
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return AnimatedBuilder(
      animation: widget.scrollController ?? const AlwaysStoppedAnimation(0.0), // Безопасное использование
      builder: (context, child) {
        final titleOpacity = _currentOpacity;
        final appBarOpacity = _currentDensity;
        
        return SliverAppBar(
          pinned: true,
          stretch: true,
          backgroundColor: Colors.transparent,
          expandedHeight: widget.showScrollAnimation ? 120 : 60, // Уменьшаем высоту для обычного режима
          
          // Используем наш оптимизированный GlassKit
          flexibleSpace: GlassKit.liquidGlass(
            radius: 0,
            isDark: isDark,
            opacity: appBarOpacity, // Динамическая прозрачность
            useBlur: true, // В ШАПКЕ БЛЮР ОСТАВЛЯЕМ (это красиво!)
            child: Container(), // УБИРАЕМ FlexibleSpaceBar с заголовком
          ),
          title: Row(
            children: [
              const Icon(Icons.blur_on, color: Colors.blueAccent, size: 32),
              const SizedBox(width: 8),
              Flexible(  // Добавили Flexible чтобы текст не переполнял
                child: Opacity(
                  opacity: titleOpacity,
                  child: Text(
                    widget.title.toUpperCase(), 
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black.withOpacity(0.9), // Явный контраст для светлой темы
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 20
                    ),
                    overflow: TextOverflow.ellipsis,  // Защита от overflow
                  ),
                ),
              ),
            ],
          ),
          actions: widget.actions ?? [],
          // Заменили небезопасное распаковывание на безопасное
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
      },
    );
  }
}
