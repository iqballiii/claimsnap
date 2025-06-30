import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VehicleDiagramWidget extends StatefulWidget {
  final List<Map<String, dynamic>> damageItems;

  const VehicleDiagramWidget({
    super.key,
    required this.damageItems,
  });

  @override
  State<VehicleDiagramWidget> createState() => _VehicleDiagramWidgetState();
}

class _VehicleDiagramWidgetState extends State<VehicleDiagramWidget> {
  String? selectedDamageId;

  @override
  Widget build(BuildContext context) {
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
              CustomIconWidget(
                iconName: 'directions_car',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                "Vehicle Damage Map",
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                // Vehicle outline
                Center(
                  child: Container(
                    width: 60.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Front section
                        Positioned(
                          top: 0,
                          left: 15.w,
                          right: 15.w,
                          child: Container(
                            height: 5.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        // Rear section
                        Positioned(
                          bottom: 0,
                          left: 15.w,
                          right: 15.w,
                          child: Container(
                            height: 5.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        // Damage markers
                        ...widget.damageItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final location =
                              item["location"] as Map<String, dynamic>;
                          final severity = item["severity"] as String;

                          Color damageColor = _getSeverityColor(severity);

                          return Positioned(
                            left: (location["x"] as double) * 60.w,
                            top: (location["y"] as double) * 30.h,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDamageId =
                                      selectedDamageId == item["id"].toString()
                                          ? null
                                          : item["id"].toString();
                                });
                              },
                              child: Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: damageColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: damageColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selectedDamageId != null) ...[
            SizedBox(height: 2.h),
            _buildDamageDetails(),
          ],
          SizedBox(height: 2.h),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDamageDetails() {
    final selectedItem = widget.damageItems.firstWhere(
      (item) => item["id"].toString() == selectedDamageId,
    );

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: _getSeverityColor(selectedItem["severity"] as String),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  selectedItem["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ),
              Text(
                "${selectedItem["confidence"]}% confidence",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            selectedItem["description"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 1.h),
          Text(
            "Estimated Cost: ${selectedItem["estimatedCost"]}",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Severity Legend",
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _buildLegendItem("Severe", AppTheme.errorLight),
            SizedBox(width: 4.w),
            _buildLegendItem("Moderate", AppTheme.warningLight),
            SizedBox(width: 4.w),
            _buildLegendItem("Minor", AppTheme.successLight),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
        ),
      ],
    );
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
