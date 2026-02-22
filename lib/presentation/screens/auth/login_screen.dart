import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';

/// HAI3 Zen-Slider Login Screen
/// Step 1: identifier (email / VT-ID / nickname) + method selector
/// Step 2: identifier freezes at top, password field slides in from below
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();

  // ── State ─────────────────────────────────────────────────────────
  int _loginMethodIndex = 0;
  bool _step2 = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  // ── Animations ────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _stepController;
  late final Animation<double> _frozenOpacity;
  late final Animation<double> _passwordSlide;
  late final Animation<double> _passwordFade;

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

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _frozenOpacity = Tween<double>(begin: 1.0, end: 0.45).animate(
      CurvedAnimation(
        parent: _stepController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _passwordSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _stepController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _passwordFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stepController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _stepController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────
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
        return TextInputType.visiblePassword;
      case 2:
        return TextInputType.name;
      default:
        return TextInputType.text;
    }
  }

  void _selectMethod(int index) {
    if (_loginMethodIndex == index || _step2) return;
    setState(() => _loginMethodIndex = index);
  }

  // ── Step 1 → Step 2 ───────────────────────────────────────────────
  void _onLetsStart() {
    final l10n = AppLocalizations.of(context)!;
    if (_identifierController.text.trim().isEmpty) {
      setState(() => _errorText = l10n.login_error_empty);
      return;
    }
    setState(() {
      _step2 = true;
      _errorText = null;
    });
    _stepController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _passwordFocus.requestFocus();
    });
  }

  // ── Back to Step 1 ────────────────────────────────────────────────
  void _onBackToStep1() {
    setState(() {
      _step2 = false;
      _errorText = null;
      _passwordController.clear();
    });
    _stepController.reverse();
  }

  // ── Final Login ───────────────────────────────────────────────────
  Future<void> _onLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text.isEmpty) {
      setState(() => _errorText = l10n.login_error_empty_password);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final result = await context.read<AuthController>().loginWithCredentials(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (result.success) {
        context.go(AppRoutes.home);
      } else {
        setState(() => _errorText = result.error ?? l10n.login_error_network);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorText =
            '${AppLocalizations.of(context)!.login_error_network}: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Social auth ───────────────────────────────────────────────────
  void _onSignInWithGoogle() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onSignInWithApple() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onRegister() {
    // TODO: навигация на экран регистрации
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
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
                          'VTALK',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 10,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Auth card ──────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [AppShadows.md],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Identifier block (dims on step 2)
                              AnimatedBuilder(
                                animation: _stepController,
                                builder: (context, child) {
                                  if (!_step2 && _stepController.value == 0) {
                                    return child!;
                                  }
                                  return Opacity(
                                    opacity: _frozenOpacity.value,
                                    child: child,
                                  );
                                },
                                child: Column(
                                  children: [
                                    if (_step2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: _onBackToStep1,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back_ios_new_rounded,
                                                size: 14,
                                                color: AppColors.primary
                                                    .withOpacity(0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  l10n.login_change_identifier,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.primary
                                                        .withOpacity(0.7),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    AiryInputField(
                                      controller: _identifierController,
                                      label: l10n.login_label,
                                      hint: _getLoginHint(l10n),
                                      keyboardType: _getKeyboardType(),
                                      readOnly: _step2,
                                    ),

                                    if (!_step2) ...[
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
                                  ],
                                ),
                              ),

                              // Password block (slides in on step 2)
                              AnimatedBuilder(
                                animation: _stepController,
                                builder: (context, child) {
                                  if (_stepController.value == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Opacity(
                                    opacity: _passwordFade.value,
                                    child: Transform.translate(
                                      offset:
                                          Offset(0, _passwordSlide.value),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    AiryInputField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      label: l10n.login_password_label,
                                      hint: l10n.login_password_hint,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: _obscurePassword,
                                      onSubmitted: (_) => _onLogin(),
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Error
                              if (_errorText != null) ...[
                                const SizedBox(height: 12),
                                AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      color: Color(0xFFFF3B30),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Primary button
                        _ZenButton(
                          onPressed: _isLoading
                              ? null
                              : (_step2 ? _onLogin : _onLetsStart),
                          backgroundColor: AppColors.primary,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    _step2
                                        ? l10n.login_button_submit
                                        : l10n.login_primary_button,
                                    key: ValueKey(_step2),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),

                        // Forgot password — step 2 only
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: _step2
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      // TODO: recovery screen
                                    },
                                    child: Text(
                                      l10n.login_forgot_password,
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Divider + social — step 1 only
                        AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          child: !_step2
                              ? Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    _ZenDivider(label: l10n.login_divider_or),
                                    const SizedBox(height: 24),
                                    _ZenButton(
                                      onPressed: _onSignInWithGoogle,
                                      backgroundColor: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.g_mobiledata_rounded,
                                            color: AppColors.onSurface,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              l10n.login_google,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w500),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _ZenButton(
                                      onPressed: _onSignInWithApple,
                                      backgroundColor: AppColors.onSurface,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.apple,
                                              color: Colors.white, size: 22),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              l10n.login_apple,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Fixed footer ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24),
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
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
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

// ── Вспомогательные виджеты ───────────────────────────────────────────────────

class _ZenButton extends StatelessWidget {
  final VoidCallback? onPressed;
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
    final bool disabled = onPressed == null;
    return AnimatedOpacity(
      opacity: disabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: isLight
              ? Border.all(color: AppColors.onSurface.withOpacity(0.08))
              : null,
          boxShadow: disabled
              ? null
              : [
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
        children: List<Widget>.generate(labels.length, (index) {
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
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
            child: Divider(color: AppColors.onSurface.withOpacity(0.06))),
      ],
    );
  }
}