import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogoHeaderWidget extends StatelessWidget {
  const LogoHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(),
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'ClaimSnap',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'Smart Insurance Claims',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
