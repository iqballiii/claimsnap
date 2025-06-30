import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClaimCardWidget extends StatelessWidget {
  final InsuranceClaim claim;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  const ClaimCardWidget({
    super.key,
    required this.claim,
    this.onTap,
    this.onEdit,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shadowColor: AppTheme.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with claim number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        claim.claimNumber,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    _buildStatusChip(),
                  ],
                ),

                SizedBox(height: 2.h),

                // Vehicle and damage info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail image
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.backgroundLight,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: claim.primaryImage?.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: claim.primaryImage!.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppTheme.backgroundLight,
                                  child: Icon(
                                    Icons.image,
                                    color: AppTheme.textSecondaryLight,
                                    size: 8.w,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppTheme.backgroundLight,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppTheme.textSecondaryLight,
                                    size: 8.w,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppTheme.backgroundLight,
                                child: Icon(
                                  Icons.directions_car,
                                  color: AppTheme.textSecondaryLight,
                                  size: 8.w,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(width: 4.w),

                    // Claim details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle info
                          Text(
                            claim.vehicle?.displayName ?? 'Vehicle Information',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 1.h),

                          // Incident description
                          Text(
                            claim.incidentDescription,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 1.h),

                          // Location and date
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 4.w,
                                color: AppTheme.textSecondaryLight,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  claim.incidentLocation,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0.5.h),

                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 4.w,
                                color: AppTheme.textSecondaryLight,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _formatDate(claim.incidentDate),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Footer with amount and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Amount',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        Text(
                          claim.formattedEstimatedAmount,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (claim.hasImages) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 3.w,
                                  color: AppTheme.primaryLight,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${claim.imageCount}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.primaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: Icon(
                              Icons.edit_outlined,
                              color: AppTheme.textSecondaryLight,
                              size: 5.w,
                            ),
                            padding: EdgeInsets.all(1.w),
                            constraints: BoxConstraints(
                              minWidth: 8.w,
                              minHeight: 8.w,
                            ),
                          ),
                        if (onShare != null)
                          IconButton(
                            onPressed: onShare,
                            icon: Icon(
                              Icons.share_outlined,
                              color: AppTheme.textSecondaryLight,
                              size: 5.w,
                            ),
                            padding: EdgeInsets.all(1.w),
                            constraints: BoxConstraints(
                              minWidth: 8.w,
                              minHeight: 8.w,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor = AppTheme.getStatusColor(claim.status.dbValue);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 0.5.h,
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Text(
        claim.statusDisplayName,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
