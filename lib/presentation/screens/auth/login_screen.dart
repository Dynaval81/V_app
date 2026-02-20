import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';

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
          content: Text(_getLoginHint(AppLocalizations.of(context)!)),
          backgroundColor: AppColors.onSurface,
          behavior: SnackBarBehavior.floating,
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
    // TODO: навигация на регистрацию
  }

  void _selectMethod(int index) {
    if (_loginMethodIndex == index) return;
    setState(() => _loginMethodIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // ── Скроллируемая область ──────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/images/logo_bnb.png',
                          width: 100,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "VTALK",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 10,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [AppShadows.md],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
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
                        _ZenButton(
                          onPressed: _onLetsStart,
                          backgroundColor: AppColors.primary,
                          child: Text(l10n.login_primary_button,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        _ZenDivider(label: l10n.login_divider_or),
                        const SizedBox(height: 24),
                        _ZenButton(
                          onPressed: _onSignInWithGoogle,
                          backgroundColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, color: AppColors.onSurface, size: 32),
                              const SizedBox(width: 4),
                              Text(l10n.login_google, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ZenButton(
                          onPressed: _onSignInWithApple,
                          backgroundColor: AppColors.onSurface,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(l10n.login_apple, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40), // Место для тени последней кнопки
                      ],
                    ),
                  ),
                ),
              ),

              // ── Фиксированный футер (Регистрация) ───────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24), // Отступ, чтобы тень сверху не резалась
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.onSurface.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: _onRegister,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(text: l10n.login_no_account),
                              TextSpan(
                                text: l10n.login_register,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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

// ── Вспомогательные виджеты ──────────────────────────────────────────

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
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isLight ? Border.all(color: AppColors.onSurface.withOpacity(0.08)) : null,
        boxShadow: [
          isLight 
            ? AppShadows.sm 
            : BoxShadow(
                color: backgroundColor.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
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
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(16),
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
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive ? [AppShadows.sm] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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
        Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
      ],
    );
  }
}