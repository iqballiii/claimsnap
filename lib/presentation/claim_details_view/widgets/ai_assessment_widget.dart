import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiAssessmentWidget extends StatefulWidget {
  final Map<String, dynamic> assessment;

  const AiAssessmentWidget({
    super.key,
    required this.assessment,
  });

  @override
  State<AiAssessmentWidget> createState() => _AiAssessmentWidgetState();
}

class _AiAssessmentWidgetState extends State<AiAssessmentWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.colorScheme.tertiary,
                        AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'psychology',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Damage Assessment',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Confidence: ${widget.assessment["confidence"]}',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.successLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildQuickSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Damage Type',
                  widget.assessment["damageType"] as String,
                  'build',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Severity',
                  widget.assessment["severity"] as String,
                  'warning',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildSummaryItem(
                  'Estimate',
                  widget.assessment["repairEstimate"] as String,
                  'attach_money',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String iconName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 3.h),
          Text(
            'Detailed Analysis',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Text(
              widget.assessment["details"] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          _buildAnalysisMetrics(),
          SizedBox(height: 3.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAnalysisMetrics() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Metrics',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Processing Time',
                  '2.3 seconds',
                  'timer',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMetricItem(
                  'Images Analyzed',
                  '4 photos',
                  'image',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Model Version',
                  'v2.1.3',
                  'model_training',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMetricItem(
                  'Last Updated',
                  'Jan 15, 2024',
                  'update',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _requestReanalysis(),
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            label: Text('Re-analyze'),
            style: AppTheme.lightTheme.outlinedButtonTheme.style,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewDetailedReport(),
            icon: CustomIconWidget(
              iconName: 'description',
              color: Colors.white,
              size: 18,
            ),
            label: Text('Full Report'),
            style: AppTheme.lightTheme.elevatedButtonTheme.style,
          ),
        ),
      ],
    );
  }

  void _requestReanalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requesting AI re-analysis...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _viewDetailedReport() {
    Navigator.pushNamed(context, '/ai-damage-assessment');
  }
}
