import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusActionsWidget extends StatelessWidget {
  final String status;

  const StatusActionsWidget({
    super.key,
    required this.status,
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
            'Available Actions',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildStatusSpecificActions(context),
          SizedBox(height: 3.h),
          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 3.h),
          _buildGeneralActions(context),
        ],
      ),
    );
  }

  Widget _buildStatusSpecificActions(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'processing':
        return _buildProcessingActions(context);
      case 'pending':
        return _buildPendingActions(context);
      case 'approved':
        return _buildApprovedActions(context);
      case 'rejected':
        return _buildRejectedActions(context);
      default:
        return _buildDefaultActions(context);
    }
  }

  Widget _buildProcessingActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Upload Additional Photos',
          'camera_alt',
          'Add more evidence to support your claim',
          AppTheme.lightTheme.colorScheme.primary,
          () => Navigator.pushNamed(context, '/camera-capture-interface'),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context,
          'Contact Adjuster',
          'phone',
          'Speak directly with your assigned adjuster',
          AppTheme.lightTheme.colorScheme.secondary,
          () => _contactAdjuster(context),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context,
          'Track Progress',
          'timeline',
          'View detailed claim timeline and updates',
          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          () => _trackProgress(context),
        ),
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Provide Additional Information',
          'info',
          'Submit any requested documentation',
          AppTheme.warningLight,
          () => _provideInfo(context),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context,
          'Schedule Inspection',
          'event',
          'Book an appointment for vehicle inspection',
          AppTheme.lightTheme.colorScheme.primary,
          () => _scheduleInspection(context),
        ),
      ],
    );
  }

  Widget _buildApprovedActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Accept Settlement',
          'check_circle',
          'Accept the approved settlement amount',
          AppTheme.successLight,
          () => _acceptSettlement(context),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context,
          'Request Review',
          'rate_review',
          'Request a review of the settlement amount',
          AppTheme.lightTheme.colorScheme.secondary,
          () => _requestReview(context),
        ),
      ],
    );
  }

  Widget _buildRejectedActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Appeal Decision',
          'gavel',
          'Submit an appeal with additional evidence',
          AppTheme.errorLight,
          () => _appealDecision(context),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context,
          'Request Explanation',
          'help',
          'Get detailed reasons for claim rejection',
          AppTheme.lightTheme.colorScheme.secondary,
          () => _requestExplanation(context),
        ),
      ],
    );
  }

  Widget _buildDefaultActions(BuildContext context) {
    return _buildActionButton(
      context,
      'View Claim Details',
      'visibility',
      'Review all claim information and documents',
      AppTheme.lightTheme.colorScheme.primary,
      () => _viewDetails(context),
    );
  }

  Widget _buildGeneralActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Actions',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryActionButton(
                context,
                'Share Claim',
                'share',
                () => _shareClaim(context),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSecondaryActionButton(
                context,
                'Print Details',
                'print',
                () => _printDetails(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryActionButton(
                context,
                'Download PDF',
                'download',
                () => _downloadPDF(context),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSecondaryActionButton(
                context,
                'Get Help',
                'support',
                () => _getHelp(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String iconName,
    String description,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 18,
      ),
      label: Text(title),
      style: AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        ),
      ),
    );
  }

  // Action handlers
  void _contactAdjuster(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        title: Text(
          'Contact Adjuster',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'How would you like to contact your adjuster?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement email functionality
            },
            child: Text('Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement call functionality
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _trackProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing claim progress timeline...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _provideInfo(BuildContext context) {
    Navigator.pushNamed(context, '/camera-capture-interface');
  }

  void _scheduleInspection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening inspection scheduler...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _acceptSettlement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        title: Text(
          'Accept Settlement',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to accept the settlement offer? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settlement accepted successfully'),
                  backgroundColor:
                      AppTheme.lightTheme.snackBarTheme.backgroundColor,
                ),
              );
            },
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _requestReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settlement review requested'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _appealDecision(BuildContext context) {
    Navigator.pushNamed(context, '/claims-dashboard');
  }

  void _requestExplanation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Explanation request sent'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _viewDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing claim details...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _shareClaim(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing claim details...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _printDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preparing claim for printing...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _downloadPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading claim PDF...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _getHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening help center...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }
}
