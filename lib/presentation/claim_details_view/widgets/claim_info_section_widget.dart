import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClaimInfoSectionWidget extends StatelessWidget {
  final Map<String, dynamic> claimData;

  const ClaimInfoSectionWidget({
    super.key,
    required this.claimData,
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
            'Claim Information',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoRow(
            'Incident Date',
            _formatIncidentDate(claimData["incidentDate"] as String),
            'event',
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Location',
            claimData["location"] as String,
            'location_on',
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Policy Number',
            claimData["policyNumber"] as String,
            'description',
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Vehicle',
            claimData["vehicleInfo"] as String,
            'directions_car',
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Deductible',
            claimData["deductible"] as String,
            'account_balance_wallet',
          ),
          SizedBox(height: 3.h),
          Divider(
            color: AppTheme.lightTheme.dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 3.h),
          Text(
            'Assigned Adjuster',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAdjusterInfo(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String iconName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdjusterInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                child: Text(
                  (claimData["adjusterName"] as String)
                      .split(' ')
                      .map((name) => name[0])
                      .join(''),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claimData["adjusterName"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Insurance Adjuster',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _makePhoneCall(claimData["adjusterPhone"] as String),
                  icon: CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Call'),
                  style:
                      AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _sendEmail(claimData["adjusterEmail"] as String),
                  icon: CustomIconWidget(
                    iconName: 'email',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Email'),
                  style:
                      AppTheme.lightTheme.outlinedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatIncidentDate(String dateString) {
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _makePhoneCall(String phoneNumber) {
    // Implement phone call functionality
    print('Calling: $phoneNumber');
  }

  void _sendEmail(String email) {
    // Implement email functionality
    print('Emailing: $email');
  }
}
