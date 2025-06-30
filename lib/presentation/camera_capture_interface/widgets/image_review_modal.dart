import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ImageReviewModal extends StatefulWidget {
  final String imageUrl;
  final double confidenceScore;
  final VoidCallback onAccept;
  final VoidCallback onRetake;

  const ImageReviewModal({
    super.key,
    required this.imageUrl,
    required this.confidenceScore,
    required this.onAccept,
    required this.onRetake,
  });

  @override
  State<ImageReviewModal> createState() => _ImageReviewModalState();
}

class _ImageReviewModalState extends State<ImageReviewModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 100.w,
            height: 100.h,
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildReviewCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxHeight: 80.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),

          // Image preview
          _buildImagePreview(),

          // AI Analysis results
          _buildAnalysisResults(),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'psychology',
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Analysis Complete',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Review your captured image',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 35.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: CustomImageWidget(
          imageUrl: widget.imageUrl,
          width: double.infinity,
          height: 35.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Confidence score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Damage Detection Confidence',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(widget.confidenceScore * 100).toInt()}%',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: _getConfidenceColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Progress bar
          LinearProgressIndicator(
            value: widget.confidenceScore,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
          ),

          SizedBox(height: 2.h),

          // Analysis details
          Row(
            children: [
              Expanded(
                child: _buildAnalysisItem(
                  icon: 'visibility',
                  label: 'Image Quality',
                  value: 'Excellent',
                  color: AppTheme.successLight,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildAnalysisItem(
                  icon: 'wb_sunny',
                  label: 'Lighting',
                  value: 'Good',
                  color: AppTheme.warningLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onRetake,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 18,
              ),
              label: Text('Retake'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onAccept,
              icon: CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 18,
              ),
              label: Text('Accept'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (widget.confidenceScore >= 0.8) {
      return AppTheme.successLight;
    } else if (widget.confidenceScore >= 0.6) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.errorLight;
    }
  }
}
