import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_button.dart';
import 'package:vtalk_app/presentation/atoms/airy_input_field.dart';

// Airy white style – scaffold is white; inputs use surface.

/// HAI3 Auth: Minimal login – Phone/Email + Let's Start (Airy white).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onLetsStart() {
    context.read<AuthController>().login();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 22,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your phone or email',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                AiryInputField(
                  controller: _emailController,
                  label: 'Phone or Email',
                  hint: 'Enter your phone number or email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                AiryButton(
                  text: "Let's Start",
                  onPressed: _onLetsStart,
                  fullWidth: true,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
