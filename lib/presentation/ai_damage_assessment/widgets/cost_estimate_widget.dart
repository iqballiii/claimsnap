import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CostEstimateWidget extends StatelessWidget {
  final List<Map<String, dynamic>> damageItems;

  const CostEstimateWidget({
    super.key,
    required this.damageItems,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinCost = _calculateTotalCost(isMin: true);
    final totalMaxCost = _calculateTotalCost(isMin: false);

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
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'attach_money',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Repair Cost Estimate",
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    Text(
                      "Preliminary assessment",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Total cost display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Total Estimated Cost",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "\$${totalMinCost.toStringAsFixed(0)} - \$${totalMaxCost.toStringAsFixed(0)}",
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "USD",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Individual cost breakdown
          Text(
            "Cost Breakdown",
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: damageItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final item = damageItems[index];
              return _buildCostBreakdownItem(item);
            },
          ),
          SizedBox(height: 3.h),
          // Disclaimer
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Important Notice",
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.warningLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "These estimates are preliminary and based on AI analysis. Final costs may vary after physical inspection by a certified technician. Labor costs, parts availability, and regional pricing differences are not included.",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownItem(Map<String, dynamic> item) {
    final severity = item["severity"] as String;
    final title = item["title"] as String;
    final costRange = item["estimatedCost"] as String;
    final confidence = item["confidence"] as int;

    Color severityColor = _getSeverityColor(severity);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      severity.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "•",
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "$confidence% confidence",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            costRange,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalCost({required bool isMin}) {
    double total = 0.0;

    for (final item in damageItems) {
      final costRange = item["estimatedCost"] as String;
      final costs = _parseCostRange(costRange);
      total += isMin ? costs["min"]! : costs["max"]!;
    }

    return total;
  }

  Map<String, double> _parseCostRange(String costRange) {
    // Parse cost range like "\$450 - \$650"
    final cleanRange = costRange.replaceAll('\$', '').replaceAll(',', '');
    final parts = cleanRange.split(' - ');

    return {
      "min": double.tryParse(parts[0]) ?? 0.0,
      "max": double.tryParse(parts.length > 1 ? parts[1] : parts[0]) ?? 0.0,
    };
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppTheme.errorLight;
      case 'moderate':
        return AppTheme.warningLight;
      case 'minor':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }
}
