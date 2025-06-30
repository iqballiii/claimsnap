import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoGalleryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> photos;

  const PhotoGalleryWidget({
    super.key,
    required this.photos,
  });

  @override
  State<PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {
  int selectedPhotoIndex = 0;
  bool isZoomed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  "Analysis Photos",
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.photos.length} photos",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Main photo display
          GestureDetector(
            onTap: () => _showFullScreenPhoto(selectedPhotoIndex),
            child: Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl:
                          widget.photos[selectedPhotoIndex]["url"] as String,
                      width: double.infinity,
                      height: 30.h,
                      fit: BoxFit.cover,
                    ),
                    // Damage annotations overlay
                    ..._buildDamageAnnotations(),
                    // Zoom indicator
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomIconWidget(
                          iconName: 'zoom_in',
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Photo thumbnails
          SizedBox(
            height: 12.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photos.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final isSelected = index == selectedPhotoIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPhotoIndex = index;
                    });
                  },
                  child: Container(
                    width: 20.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          CustomImageWidget(
                            imageUrl: widget.photos[index]["url"] as String,
                            width: 20.w,
                            height: 12.h,
                            fit: BoxFit.cover,
                          ),
                          if (isSelected)
                            Container(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                            ),
                          // Annotation count indicator
                          Positioned(
                            top: 1.w,
                            right: 1.w,
                            child: Container(
                              padding: EdgeInsets.all(0.5.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                ((widget.photos[index]["annotations"] as List)
                                        .length)
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          // Photo details
          _buildPhotoDetails(),
        ],
      ),
    );
  }

  List<Widget> _buildDamageAnnotations() {
    final annotations =
        widget.photos[selectedPhotoIndex]["annotations"] as List;
    return annotations.asMap().entries.map((entry) {
      final index = entry.key;
      final annotation = entry.value as Map<String, dynamic>;
      final severity = annotation["severity"] as String;

      Color annotationColor = _getSeverityColor(severity);

      return Positioned(
        left: (20 + index * 15).w,
        top: (5 + index * 8).h,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: annotationColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            annotation["area"].toString().replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPhotoDetails() {
    final currentPhoto = widget.photos[selectedPhotoIndex];
    final annotations = currentPhoto["annotations"] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Photo ${selectedPhotoIndex + 1} of ${widget.photos.length}",
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Text(
          "${annotations.length} damage annotation${annotations.length != 1 ? 's' : ''} detected",
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: annotations.map((annotation) {
            final severity = annotation["severity"] as String;
            final area = annotation["area"] as String;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _getSeverityColor(severity).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSeverityColor(severity).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                area.replaceAll('_', ' ').toUpperCase(),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _getSeverityColor(severity),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showFullScreenPhoto(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(4.w),
                minScale: 0.5,
                maxScale: 3.0,
                child: CustomImageWidget(
                  imageUrl: widget.photos[index]["url"] as String,
                  width: 90.w,
                  height: 70.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 4.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppTheme.errorLight;
      case 'moderate':
        return AppTheme.warningLight;
      case 'minor':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }
}
