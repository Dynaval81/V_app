import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// 🎨 Airy Chat Header - L4 UI Component
/// Glassmorphism effect with HAI3 compliance
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
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: _buildGlassmorphismHeader(context),
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  /// 🎨 Build glassmorphism header background
  Widget _buildGlassmorphismHeader(BuildContext context) {
    return Container(
      height: 100, // Extended height for proper blur
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000000), // Pure black at top
            Color(0x1A000000), // Slightly transparent at bottom
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF121212).withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📝 Build title with iOS/Telegram style
  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: Color(0xFF121212),
        fontSize: 32, // Large as requested
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 🔙 Build leading widget (back button)
  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF121212),
          size: 24,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }
    return null;
  }

  /// 🔧 Build actions (edit button or custom action)
  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];
    
    if (action != null) {
      actions.add(action!);
    } else if (onEditPressed != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.edit_note_rounded,
            color: Color(0xFF121212),
            size: 28, // Large as requested
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
