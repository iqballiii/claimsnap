import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AIGuidanceWidget extends StatefulWidget {
  final String guidanceText;
  final bool isProcessing;

  const AIGuidanceWidget({
    super.key,
    required this.guidanceText,
    required this.isProcessing,
  });

  @override
  State<AIGuidanceWidget> createState() => _AIGuidanceWidgetState();
}

class _AIGuidanceWidgetState extends State<AIGuidanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AIGuidanceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guidanceText != widget.guidanceText) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15.h,
      left: 4.w,
      right: 4.w,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildGuidanceCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuidanceCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: _getGuidanceColor().withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _getGuidanceIcon(),
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Guidance',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.guidanceText,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isProcessing)
            Container(
              padding: EdgeInsets.all(2.w),
              child: SizedBox(
                width: 4.w,
                height: 4.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getGuidanceColor() {
    if (widget.isProcessing) {
      return AppTheme.warningLight;
    }

    if (widget.guidanceText.toLowerCase().contains('good') ||
        widget.guidanceText.toLowerCase().contains('perfect') ||
        widget.guidanceText.toLowerCase().contains('excellent')) {
      return AppTheme.successLight;
    }

    if (widget.guidanceText.toLowerCase().contains('move') ||
        widget.guidanceText.toLowerCase().contains('closer') ||
        widget.guidanceText.toLowerCase().contains('angle')) {
      return AppTheme.warningLight;
    }

    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _getGuidanceIcon() {
    if (widget.isProcessing) {
      return 'psychology';
    }

    if (widget.guidanceText.toLowerCase().contains('good') ||
        widget.guidanceText.toLowerCase().contains('perfect')) {
      return 'check_circle';
    }

    if (widget.guidanceText.toLowerCase().contains('move') ||
        widget.guidanceText.toLowerCase().contains('closer')) {
      return 'zoom_in';
    }

    if (widget.guidanceText.toLowerCase().contains('angle')) {
      return 'rotate_right';
    }

    if (widget.guidanceText.toLowerCase().contains('lighting')) {
      return 'wb_sunny';
    }

    if (widget.guidanceText.toLowerCase().contains('steady')) {
      return 'center_focus_strong';
    }

    return 'camera_alt';
  }
}
