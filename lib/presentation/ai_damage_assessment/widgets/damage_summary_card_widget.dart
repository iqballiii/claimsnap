import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DamageSummaryCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> damageItems;

  const DamageSummaryCardWidget({
    super.key,
    required this.damageItems,
  });

  @override
  Widget build(BuildContext context) {
    final int totalDamages = damageItems.length;
    final int severeDamages = damageItems
        .where((item) => (item["severity"] as String) == "severe")
        .length;
    final int moderateDamages = damageItems
        .where((item) => (item["severity"] as String) == "moderate")
        .length;
    final int minorDamages = damageItems
        .where((item) => (item["severity"] as String) == "minor")
        .length;

    final double averageConfidence = damageItems.isNotEmpty
        ? damageItems
                .map((item) => item["confidence"] as int)
                .reduce((a, b) => a + b) /
            damageItems.length
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'assessment',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Damage Summary",
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    Text(
                      "$totalDamages damage${totalDamages != 1 ? 's' : ''} detected",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: averageConfidence >= 90
                      ? AppTheme.successLight.withValues(alpha: 0.1)
                      : averageConfidence >= 80
                          ? AppTheme.warningLight.withValues(alpha: 0.1)
                          : AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${averageConfidence.toInt()}% Confidence",
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: averageConfidence >= 90
                        ? AppTheme.successLight
                        : averageConfidence >= 80
                            ? AppTheme.warningLight
                            : AppTheme.errorLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSeverityCard(
                  "Severe",
                  severeDamages,
                  AppTheme.errorLight,
                  'dangerous',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSeverityCard(
                  "Moderate",
                  moderateDamages,
                  AppTheme.warningLight,
                  'warning',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSeverityCard(
                  "Minor",
                  minorDamages,
                  AppTheme.successLight,
                  'info',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityCard(
    String label,
    int count,
    Color color,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
