import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricAuthWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onBiometricAuth;

  const BiometricAuthWidget({
    super.key,
    required this.isLoading,
    required this.onBiometricAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR"
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.dividerLight,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.dividerLight,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Authentication Button
        GestureDetector(
          onTap: isLoading ? null : onBiometricAuth,
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLight),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'fingerprint',
                      color: AppTheme.primaryLight,
                      size: 8.w,
                    ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Biometric Authentication Label
        Text(
          'Use Biometric Authentication',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
