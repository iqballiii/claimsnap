import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_guidance_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/capture_controls_widget.dart';
import './widgets/image_review_modal.dart';

class CameraCaptureInterface extends StatefulWidget {
  const CameraCaptureInterface({super.key});

  @override
  State<CameraCaptureInterface> createState() => _CameraCaptureInterfaceState();
}

class _CameraCaptureInterfaceState extends State<CameraCaptureInterface>
    with TickerProviderStateMixin {
  // Camera state variables
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _showReviewModal = false;

  // Capture tracking
  int _currentPhotoCount = 3;
  final int _totalPhotosNeeded = 8;
  String? _lastCapturedImagePath;

  // AI guidance state
  String _aiGuidanceText = 'Position damage in center frame';
  final bool _isGoodLighting = true;
  final bool _isStable = true;
  double _damageConfidenceScore = 0.0;

  // Animation controllers
  late AnimationController _captureAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _captureAnimation;
  late Animation<double> _successAnimation;

  // Mock captured images data
  final List<Map<String, dynamic>> _capturedImages = [
    {
      "id": 1,
      "imageUrl":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?auto=compress&cs=tinysrgb&w=800",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "confidenceScore": 0.92,
      "damageType": "Dent",
    },
    {
      "id": 2,
      "imageUrl":
          "https://images.pexels.com/photos/2244746/pexels-photo-2244746.jpeg?auto=compress&cs=tinysrgb&w=800",
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
      "confidenceScore": 0.87,
      "damageType": "Scratch",
    },
    {
      "id": 3,
      "imageUrl":
          "https://images.pexels.com/photos/1007410/pexels-photo-1007410.jpeg?auto=compress&cs=tinysrgb&w=800",
      "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
      "confidenceScore": 0.94,
      "damageType": "Paint damage",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
    _updateAIGuidance();
  }

  void _initializeAnimations() {
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _captureAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _captureAnimationController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeCamera() {
    // Simulate camera initialization
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    });
  }

  void _updateAIGuidance() {
    final List<String> guidanceMessages = [
      'Position damage in center frame',
      'Move closer to damage',
      'Good lighting detected',
      'Hold steady for clear shot',
      'Capture from different angle',
      'Include surrounding area for context',
    ];

    // Simulate dynamic AI guidance updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _aiGuidanceText = guidanceMessages[
              (_currentPhotoCount + 1) % guidanceMessages.length];
        });
      }
    });
  }

  void _capturePhoto() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Capture animation
    await _captureAnimationController.forward();
    await _captureAnimationController.reverse();

    // Simulate photo processing
    await Future.delayed(const Duration(milliseconds: 1500));

    // Update state with new capture
    setState(() {
      _currentPhotoCount++;
      _lastCapturedImagePath =
          _capturedImages.isNotEmpty ? _capturedImages.last["imageUrl"] : null;
      _damageConfidenceScore =
          0.85 + (0.1 * (DateTime.now().millisecond % 10) / 10);
      _isProcessing = false;
      _showReviewModal = true;
    });

    // Success animation
    _successAnimationController.forward().then((_) {
      _successAnimationController.reset();
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    _updateAIGuidance();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    HapticFeedback.selectionClick();
  }

  void _closeCamera() {
    Navigator.pop(context);
  }

  void _openGallery() {
    // Navigate to gallery or show gallery picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gallery integration would open here'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _acceptPhoto() {
    setState(() {
      _showReviewModal = false;
    });

    if (_currentPhotoCount >= _totalPhotosNeeded) {
      // Navigate to AI damage assessment
      Navigator.pushNamed(context, '/ai-damage-assessment');
    }
  }

  void _retakePhoto() {
    setState(() {
      _showReviewModal = false;
      _currentPhotoCount = _currentPhotoCount > 0 ? _currentPhotoCount - 1 : 0;
    });
  }

  @override
  void dispose() {
    _captureAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview background
            _buildCameraPreview(),

            // Camera overlay with guidance frame
            CameraOverlayWidget(
              isStable: _isStable,
              isGoodLighting: _isGoodLighting,
            ),

            // Top header with photo count and close button
            _buildTopHeader(),

            // AI guidance overlay
            AIGuidanceWidget(
              guidanceText: _aiGuidanceText,
              isProcessing: _isProcessing,
            ),

            // Bottom controls
            CaptureControlsWidget(
              onCapture: _capturePhoto,
              onToggleFlash: _toggleFlash,
              onOpenGallery: _openGallery,
              isFlashOn: _isFlashOn,
              isProcessing: _isProcessing,
              lastCapturedImageUrl: _lastCapturedImagePath,
              captureAnimation: _captureAnimation,
              successAnimation: _successAnimation,
            ),

            // Processing overlay
            if (_isProcessing) _buildProcessingOverlay(),

            // Image review modal
            if (_showReviewModal)
              ImageReviewModal(
                imageUrl: _lastCapturedImagePath ?? '',
                confidenceScore: _damageConfidenceScore,
                onAccept: _acceptPhoto,
                onRetake: _retakePhoto,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox(
      width: 100.w,
      height: 100.h,
      child: _isCameraInitialized
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 80.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Camera Preview',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Initializing Camera...',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: 2.h,
      left: 4.w,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _closeCamera,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_currentPhotoCount of $_totalPhotosNeeded photos',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'info_outline',
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Processing Image...',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Text(
                'AI is analyzing damage',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
