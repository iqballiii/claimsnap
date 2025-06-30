import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_provider.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/logo_header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isBiometricAvailable = true;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();

    // Pre-fill with demo credentials for development
    _emailController.text = "user@claimsnap.com";
    _passwordController.text = "ClaimSnap123!";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _checkBiometricAvailability() {
    setState(() {
      _isBiometricAvailable = true;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(value)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (!_isValidPassword(value)) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      HapticFeedback.lightImpact();
      Navigator.pushReplacementNamed(context, '/claims-dashboard');
    } else if (mounted) {
      _showErrorMessage(
          authProvider.errorMessage ?? 'Login failed. Please try again.');
    }
  }

  Future<void> _handleBiometricAuth() async {
    try {
      // Simulate biometric authentication success
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/claims-dashboard');
      }
    } catch (e) {
      _showErrorMessage('Biometric authentication failed. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Please enter your email address first');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      _showSuccessMessage('Password reset link sent to your email');
    } else if (mounted) {
      _showErrorMessage(
          authProvider.errorMessage ?? 'Failed to send reset email');
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  void _handleRegister() {
    _showErrorMessage('Registration feature coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8.h),

                        // Logo Header
                        LogoHeaderWidget(),

                        SizedBox(height: 6.h),

                        // Login Form
                        LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          isPasswordVisible: _isPasswordVisible,
                          isLoading: authProvider.isLoading,
                          emailError: _emailError,
                          passwordError: _passwordError,
                          isFormValid: _isFormValid,
                          onPasswordVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          onEmailChanged: _validateEmail,
                          onPasswordChanged: _validatePassword,
                          onLogin: _handleLogin,
                          onForgotPassword: _handleForgotPassword,
                        ),

                        SizedBox(height: 4.h),

                        // Biometric Authentication
                        if (_isBiometricAvailable) ...[
                          BiometricAuthWidget(
                            isLoading: authProvider.isLoading,
                            onBiometricAuth: _handleBiometricAuth,
                          ),
                          SizedBox(height: 4.h),
                        ],

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New user? ',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : _handleRegister,
                              child: Text(
                                'Register',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
