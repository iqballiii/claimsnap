import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateClaim;

  const EmptyStateWidget({
    super.key,
    required this.onCreateClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'description',
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.6),
                    size: 80,
                  ),
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'add_circle_outline',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 40,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Claims Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Start by filing your first insurance claim. Take photos of the damage and let our AI help you with the assessment.',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Call-to-action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateClaim,
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white,
                  size: 24,
                ),
                label: Text(
                  'File Your First Claim',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary action
            TextButton.icon(
              onPressed: () {
                // Handle learn more
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'How It Works',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStep('1', 'Take Photos',
                            'Capture clear images of the damage'),
                        SizedBox(height: 2.h),
                        _buildStep('2', 'AI Analysis',
                            'Our AI analyzes the damage automatically'),
                        SizedBox(height: 2.h),
                        _buildStep('3', 'Submit Claim',
                            'Review and submit your claim'),
                        SizedBox(height: 2.h),
                        _buildStep('4', 'Track Progress',
                            'Monitor your claim status in real-time'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Got It',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: Text(
                'Learn How It Works',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
