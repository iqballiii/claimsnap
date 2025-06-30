import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isStable;
  final bool isGoodLighting;

  const CameraOverlayWidget({
    super.key,
    required this.isStable,
    required this.isGoodLighting,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CameraOverlayPainter(
          isStable: isStable,
          isGoodLighting: isGoodLighting,
        ),
        child: Center(
          child: Container(
            width: 70.w,
            height: 45.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: _getFrameColor(),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner indicators
                _buildCornerIndicator(Alignment.topLeft),
                _buildCornerIndicator(Alignment.topRight),
                _buildCornerIndicator(Alignment.bottomLeft),
                _buildCornerIndicator(Alignment.bottomRight),

                // Center crosshair
                Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _getFrameColor(),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 1.w,
                        height: 1.w,
                        decoration: BoxDecoration(
                          color: _getFrameColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getFrameColor() {
    if (!isStable) return AppTheme.errorLight;
    if (!isGoodLighting) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 4.w,
        height: 4.w,
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: _getFrameColor(),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CameraOverlayPainter extends CustomPainter {
  final bool isStable;
  final bool isGoodLighting;

  _CameraOverlayPainter({
    required this.isStable,
    required this.isGoodLighting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.45,
    );

    // Create path for overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
