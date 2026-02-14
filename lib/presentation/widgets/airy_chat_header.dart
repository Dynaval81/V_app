import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// 🎨 Airy Chat Header - L4 UI Component
/// Glassmorphism effect with HAI3 compliance and structured layout
class AiryChatHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEditPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? action;
  final ScrollController? scrollController;

  const AiryChatHeader({
    super.key,
    required this.title,
    this.onEditPressed,
    this.showBackButton = false,
    this.onBackPressed,
    this.action,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 120, // Increased to 120 for better proportions
      flexibleSpace: FlexibleSpaceBar(
        background: _buildGlassmorphismBackground(context),
      ),
      title: _buildTitle(context),
      centerTitle: false, // Title to the left
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  /// 🎨 Build safe glassmorphism background with ClipRect
  Widget _buildGlassmorphismBackground(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Color(0xFF000000) : Color(0xFFFFFFFF), // Adaptive background
              isDark ? Color(0x1A000000) : Color(0x1AFFFFFF), // Adaptive transparent
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📝 Build title with proper sizing
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: isDark ? Color(0xFF121212) : Color(0xFF000000),
        fontSize: 24, // Large title size
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 🔙 Build leading widget (back button)
  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Color(0xFF121212) : Color(0xFF000000),
          size: 24,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }
    return null;
  }

  /// 🔧 Build actions (search icon)
  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actions = <Widget>[];
    
    if (action != null) {
      actions.add(action!);
    } else if (onEditPressed != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.search, // Magnifying glass icon
            color: isDark ? Color(0xFF121212) : Color(0xFF000000),
            size: 24,
          ),
          onPressed: onEditPressed,
        ),
      );
    }
    
    return actions;
  }
}

/// 🎨 Simplified version for non-Sliver usage
class AiryChatHeaderSimple extends StatelessWidget {
  final String title;
  final VoidCallback? onEditPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? action;

  const AiryChatHeaderSimple({
    super.key,
    required this.title,
    this.onEditPressed,
    this.showBackButton = false,
    this.onBackPressed,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 100,
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          padding: const EdgeInsets.only(
            top: 50, // Status bar height
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔙 Back button or spacer
              showBackButton
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF121212),
                        size: 24,
                      ),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  : const SizedBox(width: 40), // Balance for edit button

              // 📝 Title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: Color(0xFF121212),
                    fontSize: 32, // Large as requested
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 🔧 Edit button or custom action
              if (action != null)
                action!
              else if (onEditPressed != null)
                IconButton(
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF121212),
                    size: 28, // Large as requested
                  ),
                  onPressed: onEditPressed,
                )
              else
                const SizedBox(width: 40), // Balance for back button
            ],
          ),
        ),
      ),
    );
  }
}
