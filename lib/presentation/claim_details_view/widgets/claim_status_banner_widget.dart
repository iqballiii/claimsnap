import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClaimStatusBannerWidget extends StatelessWidget {
  final Map<String, dynamic> claimData;

  const ClaimStatusBannerWidget({
    super.key,
    required this.claimData,
  });

  @override
  Widget build(BuildContext context) {
    String status = claimData["status"] as String;
    String lastUpdated = claimData["lastUpdated"] as String;

    Color statusColor = AppTheme.getStatusColor(status);
    String statusText = _getStatusText(status);
    String formattedDate = _formatDate(lastUpdated);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: AppTheme.getStatusGradient(status),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      statusText,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              CustomIconWidget(
                iconName: 'sync',
                color: statusColor,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Claim ${claimData["claimId"]}',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Last updated: $formattedDate',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Settlement',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  claimData["estimatedAmount"] as String,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Under Review';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'hourglass_empty';
      case 'pending':
        return 'pending';
      case 'approved':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'completed':
        return 'task_alt';
      default:
        return 'help';
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
