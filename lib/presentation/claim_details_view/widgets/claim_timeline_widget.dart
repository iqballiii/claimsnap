import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClaimTimelineWidget extends StatelessWidget {
  final List<dynamic> timeline;

  const ClaimTimelineWidget({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Claim Progress',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final step = timeline[index] as Map<String, dynamic>;
              final isLast = index == timeline.length - 1;
              return _buildTimelineItem(step, isLast);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> step, bool isLast) {
    String status = step["status"] as String;
    String stepTitle = step["step"] as String;
    String description = step["description"] as String;
    String? date = step["date"] as String?;

    Color statusColor = _getTimelineColor(status);
    IconData statusIcon = _getTimelineIcon(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: status == 'current'
                    ? statusColor
                    : status == 'completed'
                        ? statusColor
                        : AppTheme.lightTheme.colorScheme.surface,
                border: Border.all(
                  color: statusColor,
                  width: status == 'pending' ? 2 : 0,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: status == 'completed'
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 20,
                      )
                    : status == 'current'
                        ? CustomIconWidget(
                            iconName: 'radio_button_checked',
                            color: Colors.white,
                            size: 20,
                          )
                        : CustomIconWidget(
                            iconName: 'radio_button_unchecked',
                            color: statusColor,
                            size: 20,
                          ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 8.h,
                color: status == 'completed' || status == 'current'
                    ? statusColor.withValues(alpha: 0.3)
                    : AppTheme.lightTheme.dividerColor,
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stepTitle,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: status == 'current'
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (date != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDate(date),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (status == 'current')
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'In Progress',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTimelineColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'current':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'pending':
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      default:
        return AppTheme.lightTheme.dividerColor;
    }
  }

  IconData _getTimelineIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check;
      case 'current':
        return Icons.radio_button_checked;
      case 'pending':
        return Icons.radio_button_unchecked;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateString;
    }
  }
}
