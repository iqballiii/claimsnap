import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchToggle;
  final bool isSearching;
  final Map<String, dynamic>? statistics;

  const DashboardHeaderWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchToggle,
    required this.isSearching,
    this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message and search
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final userName =
                            authProvider.currentUserProfile?.fullName ?? 'User';
                        return Text(
                          'Welcome back, $userName',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Manage your insurance claims',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSearchToggle,
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
              ),
            ],
          ),

          // Search bar
          if (isSearching) ...[
            SizedBox(height: 2.h),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search claims...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondaryLight,
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              autofocus: true,
            ),
          ],

          // Statistics cards
          if (statistics != null) ...[
            SizedBox(height: 3.h),
            _buildStatisticsCards(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Claims',
            '${statistics!['total_claims'] ?? 0}',
            Icons.assignment_outlined,
            AppTheme.primaryLight,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '${statistics!['pending_claims'] ?? 0}',
            Icons.pending_outlined,
            AppTheme.warningLight,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            'Approved',
            '${statistics!['approved_claims'] ?? 0}',
            Icons.check_circle_outline,
            AppTheme.successLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
