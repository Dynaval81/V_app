import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/presentation/atoms/airy_button.dart';

/// HAI3 Settings / Account (Airy). Linked from profile icon in AppBar.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profile and app preferences.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              AiryButton(
                text: 'Sign out',
                onPressed: () {
                  context.read<AuthController>().logout();
                  context.go(AppRoutes.auth);
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
