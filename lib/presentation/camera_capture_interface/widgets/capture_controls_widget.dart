import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CaptureControlsWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleFlash;
  final VoidCallback onOpenGallery;
  final bool isFlashOn;
  final bool isProcessing;
  final String? lastCapturedImageUrl;
  final Animation<double> captureAnimation;
  final Animation<double> successAnimation;

  const CaptureControlsWidget({
    super.key,
    required this.onCapture,
    required this.onToggleFlash,
    required this.onOpenGallery,
    required this.isFlashOn,
    required this.isProcessing,
    this.lastCapturedImageUrl,
    required this.captureAnimation,
    required this.successAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 4.h,
      left: 4.w,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery thumbnail
            _buildGalleryThumbnail(),

            // Capture button
            _buildCaptureButton(),

            // Flash toggle
            _buildFlashToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryThumbnail() {
    return GestureDetector(
      onTap: onOpenGallery,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: lastCapturedImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CustomImageWidget(
                  imageUrl: lastCapturedImageUrl!,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return AnimatedBuilder(
      animation: captureAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: captureAnimation.value,
          child: GestureDetector(
            onTap: isProcessing ? null : onCapture,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                ),

                // Inner button
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: isProcessing ? AppTheme.warningLight : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: isProcessing
                      ? Center(
                          child: SizedBox(
                            width: 6.w,
                            height: 6.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),

                // Success animation overlay
                AnimatedBuilder(
                  animation: successAnimation,
                  builder: (context, child) {
                    return successAnimation.value > 0
                        ? Transform.scale(
                            scale: successAnimation.value,
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.successLight.withValues(
                                  alpha: 0.3 * (1 - successAnimation.value),
                                ),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'check',
                                  color: AppTheme.successLight,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlashToggle() {
    return GestureDetector(
      onTap: onToggleFlash,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isFlashOn
              ? AppTheme.warningLight.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: isFlashOn ? 'flash_on' : 'flash_off',
            color:
                isFlashOn ? Colors.white : Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}
