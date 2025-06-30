import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoGalleryWidget extends StatelessWidget {
  final List<String> photos;

  const PhotoGalleryWidget({
    super.key,
    required this.photos,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Damage Photos',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addMorePhotos(context),
                icon: CustomIconWidget(
                  iconName: 'add_a_photo',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('Add More'),
                style: AppTheme.lightTheme.textButtonTheme.style,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '${photos.length} photos uploaded',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return _buildPhotoItem(context, photos[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(BuildContext context, String photoUrl, int index) {
    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _viewFullImage(context, photoUrl, index),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CustomImageWidget(
                        imageUrl: photoUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 2.w,
                        right: 2.w,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CustomIconWidget(
                            iconName: 'zoom_in',
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2.w,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${photos.length}',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Damage Photo ${index + 1}',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _getPhotoTimestamp(index),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _viewFullImage(BuildContext context, String imageUrl, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _addMorePhotos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Add More Photos',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildPhotoOption(
              context,
              'Take Photo',
              'camera_alt',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera-capture-interface');
              },
            ),
            SizedBox(height: 2.h),
            _buildPhotoOption(
              context,
              'Choose from Gallery',
              'photo_library',
              () {
                Navigator.pop(context);
                // Implement gallery picker
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
      BuildContext context, String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String _getPhotoTimestamp(int index) {
    // Mock timestamps for photos
    final now = DateTime.now();
    final photoTime = now.subtract(Duration(hours: index + 1));
    return '${photoTime.hour.toString().padLeft(2, '0')}:${photoTime.minute.toString().padLeft(2, '0')}';
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareImage(),
            icon: CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: CustomImageWidget(
                imageUrl: widget.images[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  void _shareImage() {
    // Implement image sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing image...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
