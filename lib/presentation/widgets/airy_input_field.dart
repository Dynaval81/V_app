import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// 📝 HAI3 Airy Input Field
/// Generous padding and spacing for minimal, clean design
class AiryInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;

  const AiryInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📝 Label
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 📱 Input field
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.input),
            border: errorText != null
                ? Border.all(color: Color(0xFFFF3B30), width: 2)
                : Border.all(
                    color: AppColors.onSurface.withOpacity(0.2),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: AppTextStyles.input.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.input.copyWith(
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.inputPadding),
            ),
          ),
        ),
        
        // 🚨 Error text
        if (errorText != null) ...[
          SizedBox(height: AppSpacing.inputPadding),
          Text(
            errorText!,
            style: AppTextStyles.body.copyWith(
              color: Color(0xFFFF3B30),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
