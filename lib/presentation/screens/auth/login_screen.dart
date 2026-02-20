import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';

/// HAI3 Zen Login Screen
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
      case 0: return l10n.login_hint_email;
      case 1: return l10n.login_hint_vtalk_id;
      case 2: return l10n.login_hint_nickname;
      default: return l10n.login_hint_email;
    }
  }

  TextInputType _getKeyboardType() {
    switch (_loginMethodIndex) {
      case 0: return TextInputType.emailAddress;
      case 1: return TextInputType.visiblePassword;
      case 2: return TextInputType.name;
      default: return TextInputType.text;
    }
  }

  void _onLetsStart() {
    final String text = _loginController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getLoginHint(AppLocalizations.of(context)!),
            style: const TextStyle(color: Colors.white),
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

  void _onSignInWithGoogle() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onSignInWithApple() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onRegister() {
    // TODO: context.go(AppRoutes.register);
  }

  void _selectMethod(int index) {
    if (_loginMethodIndex == index) return;
    setState(() => _loginMethodIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Фон всего экрана — светло-серый, чтобы не было обрыва
      backgroundColor: const Color(0xFFF1F3F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // ── Скроллируемый контент ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 56),

                        // ── Лого + название ──────────────────────
                        Image.asset(
                          'assets/images/logo_bnb.png',
                          width: 88,
                          height: 88,
                          color: AppColors.primary,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 10,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 52),

                        // ── Карточка: поле + селектор ────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [AppShadows.md],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AiryInputField(
                                controller: _loginController,
                                label: l10n.login_label,
                                hint: _getLoginHint(l10n),
                                keyboardType: _getKeyboardType(),
                              ),
                              const SizedBox(height: 16),
                              _MethodSelector(
                                selected: _loginMethodIndex,
                                labels: [
                                  l10n.login_method_email,
                                  l10n.login_method_vtalk_id,
                                  l10n.login_method_nickname,
                                ],
                                onSelect: _selectMethod,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Основная кнопка ──────────────────────
                        _ZenButton(
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

                        _ZenDivider(label: l10n.login_divider_or),

                        const SizedBox(height: 28),

                        // ── Google ───────────────────────────────
                        _ZenButton(
                          onPressed: _onSignInWithGoogle,
                          backgroundColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded,
                                  color: AppColors.onSurface, size: 24),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.login_google,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Apple ────────────────────────────────
                        _ZenButton(
                          onPressed: _onSignInWithApple,
                          backgroundColor: AppColors.onSurface,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.login_apple,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Место для тени кнопки Apple
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Регистрация — на сером фоне с разделителем ──────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.onSurface.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: _onRegister,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(text: l10n.login_no_account),
                            TextSpan(
                              text: l10n.login_register,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Виджеты ────────────────────────────────────────────────────────────────────

class _ZenButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  const _ZenButton({
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
            ? Border.all(color: AppColors.onSurface.withOpacity(0.08))
            : null,
        boxShadow: [
          isLight
              ? AppShadows.sm
              : BoxShadow(
                  color: backgroundColor.withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
        color: const Color(0xFFF1F3F5),
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
                duration: const Duration(milliseconds: 300),
                curve: const Cubic(0.23, 1.0, 0.32, 1.0),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive ? const [AppShadows.sm] : null,
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
                        ? AppColors.primary
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

class _ZenDivider extends StatelessWidget {
  final String label;

  const _ZenDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.onSurface.withOpacity(0.08),
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
            color: AppColors.onSurface.withOpacity(0.08),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}