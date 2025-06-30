import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final List<String> activeFilters;
  final Function(String) onFilterSelected;
  final Function(String) onFilterRemoved;
  final int claimsCount;

  const FilterChipsWidget({
    super.key,
    required this.selectedFilter,
    required this.activeFilters,
    required this.onFilterSelected,
    required this.onFilterRemoved,
    required this.claimsCount,
  });

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      {'label': 'All', 'value': 'all', 'count': claimsCount},
      {
        'label': 'Pending',
        'value': 'pending',
        'count': _getStatusCount('pending')
      },
      {
        'label': 'Approved',
        'value': 'approved',
        'count': _getStatusCount('approved')
      },
      {
        'label': 'Processing',
        'value': 'processing',
        'count': _getStatusCount('processing')
      },
      {
        'label': 'Denied',
        'value': 'denied',
        'count': _getStatusCount('denied')
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results count
          Text(
            '$claimsCount ${claimsCount == 1 ? 'claim' : 'claims'} found',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 2.h),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                final isSelected = selectedFilter == filter['value'];
                final count = filter['count'] as int;

                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter['label'] as String,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (count > 0) ...[
                          SizedBox(width: 1.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w,
                              vertical: 0.2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              count.toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      onFilterSelected(filter['value'] as String);
                    },
                    backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                    selectedColor: AppTheme.lightTheme.colorScheme.primary,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                );
              }).toList(),
            ),
          ),

          // Active filters (if any)
          if (activeFilters.isNotEmpty && selectedFilter != 'all') ...[
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: activeFilters.map((filter) {
                return Chip(
                  label: Text(
                    filter.toUpperCase(),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  deleteIcon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  onDeleted: () => onFilterRemoved(filter),
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  int _getStatusCount(String status) {
    // This would normally come from the parent widget or a service
    // For now, return mock counts
    switch (status) {
      case 'pending':
        return 1;
      case 'approved':
        return 2;
      case 'processing':
        return 1;
      case 'denied':
        return 1;
      default:
        return 0;
    }
  }
}
