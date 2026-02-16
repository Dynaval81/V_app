import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_button.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';

// Airy white style – scaffold is white; inputs use surface.

/// HAI3 Auth: Minimal login – Phone/Email + Let's Start (Airy white).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _loginMethodIndex = 0;

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  String _getLoginHint(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        return TextInputType.text;
      case 2:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  Widget _buildLoginMethodToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SegmentedButton<int>(
        segments: <ButtonSegment<int>>[
          ButtonSegment<int>(
            value: 0,
            label: Text(
              l10n.login_method_email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text(
              l10n.login_method_vtalk_id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ButtonSegment<int>(
            value: 2,
            label: Text(
              l10n.login_method_nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        selected: <int>{_loginMethodIndex},
        onSelectionChanged: (newSelection) {
          final next = newSelection.isNotEmpty ? newSelection.first : _loginMethodIndex;
          if (_loginMethodIndex == next) return;
          setState(() {
            _loginMethodIndex = next;
          });
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: Colors.transparent)),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }

  void _onLetsStart() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  Widget _buildDivider() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.login_divider_or,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3))),
      ],
    );
  }

  void _onSignInWithGoogle() {
    // TODO: Implement Google Sign-In
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  void _onSignInWithApple() {
    // TODO: Implement Apple Sign-In
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'VTALK',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 26,
                      letterSpacing: 10.0,
                      fontWeight: FontWeight.w200,
                      color: const Color(0xFF1A1A1A).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.login_subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AiryInputField(
                          controller: _loginController,
                          label: l10n.login_label,
                          hint: _getLoginHint(context),
                          keyboardType: _getKeyboardType(),
                        ),
                        const SizedBox(height: 16),
                        _buildLoginMethodToggle(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onLetsStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        l10n.login_primary_button,
                        style: AppTextStyles.button.copyWith(
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AiryButton(
                      text: l10n.login_google,
                      onPressed: _onSignInWithGoogle,
                      fullWidth: true,
                      height: 52,
                      backgroundColor: Colors.white,
                      textColor: AppColors.onSurface,
                      icon: Icon(Icons.g_mobiledata_rounded, color: AppColors.onSurface, size: 24),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AiryButton(
                      text: l10n.login_apple,
                      onPressed: _onSignInWithApple,
                      fullWidth: true,
                      height: 52,
                      backgroundColor: AppColors.onSurface,
                      textColor: Colors.white,
                      icon: const Icon(Icons.apple, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
