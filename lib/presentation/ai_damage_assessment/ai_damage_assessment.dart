import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/cost_estimate_widget.dart';
import './widgets/damage_item_widget.dart';
import './widgets/damage_summary_card_widget.dart';
import './widgets/photo_gallery_widget.dart';
import './widgets/vehicle_diagram_widget.dart';

class AiDamageAssessment extends StatefulWidget {
  const AiDamageAssessment({super.key});

  @override
  State<AiDamageAssessment> createState() => _AiDamageAssessmentState();
}

class _AiDamageAssessmentState extends State<AiDamageAssessment>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isProcessing = false;
  bool _isLoading = true;
  String _processingStatus = "Analyzing damage...";

  // Mock data for AI damage assessment
  final List<Map<String, dynamic>> _damageItems = [
    {
      "id": 1,
      "title": "Front Bumper Damage",
      "severity": "moderate",
      "confidence": 92,
      "description": "Significant scratches and minor dent on front bumper",
      "affectedParts": ["Front Bumper", "Paint"],
      "estimatedCost": "\$450 - \$650",
      "photoReference":
          "https://images.pexels.com/photos/3806288/pexels-photo-3806288.jpeg",
      "location": {"x": 0.3, "y": 0.2}
    },
    {
      "id": 2,
      "title": "Headlight Assembly",
      "severity": "severe",
      "confidence": 88,
      "description": "Cracked headlight lens requiring replacement",
      "affectedParts": ["Headlight Assembly", "Electrical"],
      "estimatedCost": "\$280 - \$420",
      "photoReference":
          "https://images.pexels.com/photos/3806288/pexels-photo-3806288.jpeg",
      "location": {"x": 0.25, "y": 0.15}
    },
    {
      "id": 3,
      "title": "Side Mirror Damage",
      "severity": "minor",
      "confidence": 95,
      "description": "Minor scratches on mirror housing",
      "affectedParts": ["Side Mirror", "Paint"],
      "estimatedCost": "\$120 - \$180",
      "photoReference":
          "https://images.pexels.com/photos/3806288/pexels-photo-3806288.jpeg",
      "location": {"x": 0.15, "y": 0.3}
    }
  ];

  final List<Map<String, dynamic>> _analysisPhotos = [
    {
      "id": 1,
      "url":
          "https://images.pexels.com/photos/3806288/pexels-photo-3806288.jpeg",
      "annotations": [
        {"type": "damage", "area": "front_bumper", "severity": "moderate"}
      ]
    },
    {
      "id": 2,
      "url":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg",
      "annotations": [
        {"type": "damage", "area": "headlight", "severity": "severe"}
      ]
    },
    {
      "id": 3,
      "url":
          "https://images.pexels.com/photos/3806288/pexels-photo-3806288.jpeg",
      "annotations": [
        {"type": "damage", "area": "side_mirror", "severity": "minor"}
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _simulateProcessing();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _simulateProcessing() async {
    setState(() {
      _isProcessing = true;
      _isLoading = true;
    });

    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _processingStatus = "Identifying damage patterns...";
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _processingStatus = "Calculating repair estimates...";
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _processingStatus = "Finalizing assessment...";
    });

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isProcessing = false;
      _isLoading = false;
    });
  }

  void _regenerateAnalysis() {
    _progressController.reset();
    _simulateProcessing();
  }

  void _showAddDamageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Add Missing Damage",
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              SizedBox(height: 2.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Damage Description",
                  hintText: "Describe the damage not detected by AI",
                ),
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Severity Level",
                ),
                items: ['Minor', 'Moderate', 'Severe']
                    .map((severity) => DropdownMenuItem(
                          value: severity.toLowerCase(),
                          child: Text(severity),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              SizedBox(height: 2.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Affected Parts",
                  hintText: "List affected vehicle parts",
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Damage added successfully"),
                          ),
                        );
                      },
                      child: const Text("Add Damage"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisputeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Dispute AI Finding",
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              SizedBox(height: 2.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Damage Item",
                ),
                items: _damageItems
                    .map((item) => DropdownMenuItem(
                          value: item["id"].toString(),
                          child: Text(item["title"] as String),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              SizedBox(height: 2.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Reason for Dispute",
                  hintText: "Explain why you disagree with this assessment",
                ),
                maxLines: 4,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Dispute submitted for review"),
                          ),
                        );
                      },
                      child: const Text("Submit Dispute"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("AI Damage Assessment"),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _regenerateAnalysis,
            child: Text(
              "Regenerate",
              style: TextStyle(
                color: _isProcessing
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.5)
                    : AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isProcessing) _buildProcessingStatus(),
                  if (!_isProcessing) ...[
                    DamageSummaryCardWidget(damageItems: _damageItems),
                    SizedBox(height: 3.h),
                    VehicleDiagramWidget(damageItems: _damageItems),
                    SizedBox(height: 3.h),
                    _buildDamageItemsList(),
                    SizedBox(height: 3.h),
                    CostEstimateWidget(damageItems: _damageItems),
                    SizedBox(height: 3.h),
                    PhotoGalleryWidget(photos: _analysisPhotos),
                    SizedBox(height: 3.h),
                    _buildActionButtons(),
                    SizedBox(height: 2.h),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            "Initializing AI Analysis...",
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStatus() {
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
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  "AI Analysis in Progress",
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _processingStatus,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDamageItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Detected Damage",
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showAddDamageBottomSheet,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text("Add Missing"),
                ),
                TextButton.icon(
                  onPressed: _showDisputeBottomSheet,
                  icon: CustomIconWidget(
                    iconName: 'report_problem',
                    color: AppTheme.warningLight,
                    size: 18,
                  ),
                  label: Text(
                    "Dispute",
                    style: TextStyle(color: AppTheme.warningLight),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _damageItems.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            return DamageItemWidget(
              damageItem: _damageItems[index],
              onTap: () {
                // Handle damage item tap
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/claim-details-view');
            },
            child: const Text("Accept Assessment"),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Manual review request submitted"),
                ),
              );
            },
            child: const Text("Request Manual Review"),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          "* Estimates are preliminary and subject to physical inspection",
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
