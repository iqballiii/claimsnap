import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final bool isFormValid;
  final VoidCallback onPasswordVisibilityToggle;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isPasswordVisible,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.isFormValid,
    required this.onPasswordVisibilityToggle,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: emailController,
                focusNode: emailFocusNode,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: onEmailChanged,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(passwordFocusNode);
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: emailError != null
                          ? AppTheme.errorLight
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                  ),
                  errorText: emailError,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: AppTheme.errorLight, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: AppTheme.errorLight, width: 2.0),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                enabled: !isLoading,
                obscureText: !isPasswordVisible,
                textInputAction: TextInputAction.done,
                onChanged: onPasswordChanged,
                onFieldSubmitted: (_) {
                  if (isFormValid) {
                    onLogin();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: passwordError != null
                          ? AppTheme.errorLight
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: isLoading ? null : onPasswordVisibilityToggle,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName:
                            isPasswordVisible ? 'visibility' : 'visibility_off',
                        color: AppTheme.textSecondaryLight,
                        size: 5.w,
                      ),
                    ),
                  ),
                  errorText: passwordError,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: AppTheme.errorLight, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: AppTheme.errorLight, width: 2.0),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isLoading ? null : onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: (isFormValid && !isLoading) ? onLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? AppTheme.primaryLight
                    : AppTheme.textDisabledLight,
                foregroundColor: Colors.white,
                elevation: isFormValid ? 2.0 : 0,
                shadowColor: AppTheme.shadowLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Login',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
