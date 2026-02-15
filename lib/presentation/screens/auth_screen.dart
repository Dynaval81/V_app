import 'package:flutter/material.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/presentation/widgets/airy_input_field.dart';
import 'package:vtalk_app/presentation/widgets/airy_button.dart';

/// 🔐 HAI3 Authentication Screen
/// Airy design with generous spacing and bright blue accent
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // 🎯 Logo and title
              _buildHeader(),
              
              SizedBox(height: AppSpacing.buttonPadding * 3),
              
              // 📝 Tab bar for Login/Register
              _buildTabBar(),
              
              SizedBox(height: AppSpacing.buttonPadding),
              
              // 📱 Form content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Build header with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        // 🎯 Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A3FF), Color(0xFF0066FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.input),
            boxShadow: [AppShadows.md],
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 📝 App name
        Text(
          AppConstants.appName,
          style: AppTextStyles.h3.copyWith(
            color: Color(0xFF121212),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        
        SizedBox(height: AppSpacing.inputPadding / 2),
        
        // 📝 Tagline
        Text(
          'Secure messaging redefined',
          style: AppTextStyles.body.copyWith(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// 📝 Build tab bar
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppBorderRadius.input),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF00A3FF), Color(0xFF0066FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF757575),
        labelStyle: AppTextStyles.button,
        unselectedLabelStyle: AppTextStyles.button.copyWith(
          color: Color(0xFF757575),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  /// 🔐 Build login form
  Widget _buildLoginForm() {
    return Column(
      children: [
        // 📧 Email field
        AiryInputField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 🔒 Password field
        AiryInputField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          obscureText: !_isPasswordVisible,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF757575),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        
        SizedBox(height: AppSpacing.inputPadding / 2),
        
        // 📝 Remember me checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Text(
              'Remember me',
              style: AppTextStyles.body.copyWith(
                color: Color(0xFF757575),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(
                'Forgot password?',
                style: AppTextStyles.body.copyWith(
                  color: Color(0xFF00A3FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSpacing.buttonPadding),
        
        // 🔐 Login button
        AiryButton(
          text: 'Sign In',
          onPressed: _handleLogin,
          isLoading: _isLoading,
          fullWidth: true,
        ),
      ],
    );
  }

  /// 📝 Build register form
  Widget _buildRegisterForm() {
    return Column(
      children: [
        // 👤 Username field
        AiryInputField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a username',
          prefixIcon: Icons.person_outline,
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 📧 Email field
        AiryInputField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 🔒 Password field
        AiryInputField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a password',
          obscureText: !_isPasswordVisible,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF757575),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        
        SizedBox(height: AppSpacing.inputPadding),
        
        // 🔒 Confirm password field
        AiryInputField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Confirm your password',
          obscureText: !_isConfirmPasswordVisible,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF757575),
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
        
        SizedBox(height: AppSpacing.buttonPadding),
        
        // 📝 Register button
        AiryButton(
          text: 'Create Account',
          onPressed: _handleRegister,
          isLoading: _isLoading,
          fullWidth: true,
        ),
      ],
    );
  }

  /// 🔐 Handle login
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // TODO: Navigate to main app
        // context.go('/');
      }
    } catch (e) {
      _showError('Login failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 📝 Handle registration
  void _handleRegister() async {
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement registration logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSuccess('Account created successfully!');
        // Switch to login tab
        _tabController.animateTo(0);
      }
    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 🚨 Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
        ),
      ),
    );
  }

  /// ✅ Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF30D158),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.input),
        ),
      ),
    );
  }
}
