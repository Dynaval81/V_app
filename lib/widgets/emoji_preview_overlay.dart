import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../constants/emoji_sizes.dart';
import '../widgets/emoji_renderer.dart';

class EmojiPreviewOverlay extends StatefulWidget {
  final Widget child;
  
  const EmojiPreviewOverlay({required this.child});
  
  @override
  _EmojiPreviewOverlayState createState() => _EmojiPreviewOverlayState();
}

class _EmojiPreviewOverlayState extends State<EmojiPreviewOverlay> 
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  // Removed unused field: String? _currentEmoji;
  late AnimationController _previewController;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;
  
  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _hideTimer?.cancel();
    _previewController.dispose();
    _removeOverlay();
    super.dispose();
  }
  
  void showPreview(String emojiCode) {
    if (_overlayEntry != null) {
      _removeOverlay();
    }
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.bottom + 100,
        right: 20,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: EmojiRenderer.render(
                    emojiCode, 
                    EmojiSizes.preview,
                    semanticLabel: 'Selected emoji preview',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _previewController.forward();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Memory Leak Guard - автоудаление через 2 секунды
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      _removeOverlay();
    });
  }
  
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _previewController.reset();
    }
  }
  
  void hidePreview() {
    _hideTimer?.cancel();
    _removeOverlay();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
