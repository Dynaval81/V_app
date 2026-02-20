import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';

/// HAI3 Zen Minimalist Login Screen
/// Philosophy: vast whitespace, soft depth, single focus.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _loginController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _loginMethodIndex = 0;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _getLoginHint(AppLocalizations l10n) {
    switch (_loginMethodIndex) {
      case 0:
        return l10n.login_hint_email;
      case 1:
        return l10n.login_hint_vtalk_id;
      case 2:
        return l10n.login_hint_nickname;
      default:
        return l10n.login_hint_email;
    }
  }

  TextInputType _getKeyboardType() {
    switch (_loginMethodIndex) {
      case 0:
        return TextInputType.emailAddress;
      case 1:
        // V-Talk ID — может содержать цифры и буквы
        return TextInputType.visiblePassword;
      case 2:
        return TextInputType.name;
      default:
        return TextInputType.text;
    }
  }

  void _onLetsStart() {
    final text = _loginController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getValidationHint(),
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.onSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  String _getValidationHint() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    switch (_loginMethodIndex) {
      case 0:
        return l10n.login_hint_email;
      case 1:
        return l10n.login_hint_vtalk_id;
      case 2:
        return l10n.login_hint_nickname;
      default:
        return l10n.login_hint_email;
    }
  }

  void _onSignInWithGoogle() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onSignInWithApple() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _selectMethod(int index) {
    if (_loginMethodIndex == index) return;
    setState(() => _loginMethodIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),

                  // ── Logo ───────────────────────────────────────────────
                  const _AppLogo(),

                  const SizedBox(height: 40),

                  // ── Headline ───────────────────────────────────────────
                  Text(
                    l10n.login_title,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.login_subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Card с методом входа и инпутом ─────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MethodSelector(
                          selected: _loginMethodIndex,
                          labels: [
                            l10n.login_method_email,
                            l10n.login_method_vtalk_id,
                            l10n.login_method_nickname,
                          ],
                          onSelect: _selectMethod,
                        ),
                        const SizedBox(height: 16),
                        AiryInputField(
                          controller: _loginController,
                          label: l10n.login_label,
                          hint: _getLoginHint(l10n),
                          keyboardType: _getKeyboardType(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Primary CTA ────────────────────────────────────────
                  _ShadowButton(
                    onPressed: _onLetsStart,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      l10n.login_primary_button,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Divider ────────────────────────────────────────────
                  _ZenDivider(label: l10n.login_divider_or),

                  const SizedBox(height: 28),

                  // ── Social buttons ─────────────────────────────────────
                  _ShadowButton(
                    onPressed: _onSignInWithGoogle,
                    backgroundColor: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.g_mobiledata_rounded,
                          color: AppColors.onSurface,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.login_google,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _ShadowButton(
                    onPressed: _onSignInWithApple,
                    backgroundColor: AppColors.onSurface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apple, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.login_apple,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Atoms ──────────────────────────────────────────────────────────────────────

/// Реальный логотип приложения из assets/images/
class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.xl],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/logo_bnb.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Кнопка с мягкой тенью — заменяет AiryButton для HAI3-глубины.
class _ShadowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  const _ShadowButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLight = backgroundColor == Colors.white;
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(27),
        border: isLight
            ? Border.all(color: AppColors.onSurface.withOpacity(0.1))
            : null,
        boxShadow: [
          isLight
              ? AppShadows.md
              : BoxShadow(
                  color: backgroundColor.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(27),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Method selector: pill tabs, no heavy borders, pure ink underline feel.
class _MethodSelector extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  const _MethodSelector({
    required this.selected,
    required this.labels,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List<Widget>.generate(labels.length, (int index) {
          final bool isActive = index == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Minimal divider with centered label.
class _ZenDivider extends StatelessWidget {
  final String label;

  const _ZenDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: const Color(0xFFE8E8E8),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: const Color(0xFFE8E8E8),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}