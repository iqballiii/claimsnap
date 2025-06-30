import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DamageItemWidget extends StatefulWidget {
  final Map<String, dynamic> damageItem;
  final VoidCallback? onTap;

  const DamageItemWidget({
    super.key,
    required this.damageItem,
    this.onTap,
  });

  @override
  State<DamageItemWidget> createState() => _DamageItemWidgetState();
}

class _DamageItemWidgetState extends State<DamageItemWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.damageItem["title"] as String;
    final severity = widget.damageItem["severity"] as String;
    final confidence = widget.damageItem["confidence"] as int;
    final description = widget.damageItem["description"] as String;
    final affectedParts = widget.damageItem["affectedParts"] as List;
    final estimatedCost = widget.damageItem["estimatedCost"] as String;
    final photoReference = widget.damageItem["photoReference"] as String;

    Color severityColor = _getSeverityColor(severity);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: photoReference,
                            width: 15.w,
                            height: 15.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: severityColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          severityColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    severity.toUpperCase(),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: severityColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: confidence >= 90
                                        ? AppTheme.successLight
                                            .withValues(alpha: 0.1)
                                        : confidence >= 80
                                            ? AppTheme.warningLight
                                                .withValues(alpha: 0.1)
                                            : AppTheme.errorLight
                                                .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$confidence%",
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: confidence >= 90
                                          ? AppTheme.successLight
                                          : confidence >= 80
                                              ? AppTheme.warningLight
                                              : AppTheme.errorLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: CustomIconWidget(
                          iconName: isExpanded ? 'expand_less' : 'expand_more',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    estimatedCost,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Affected Parts",
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: affectedParts.map((part) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            part as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showPhotoDetail(context, photoReference, title);
                            },
                            icon: CustomIconWidget(
                              iconName: 'photo',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 18,
                            ),
                            label: const Text("View Photo"),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showEditDialog(context);
                            },
                            icon: CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 18,
                            ),
                            label: const Text("Edit"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50.h,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(2.w),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 50.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Damage Assessment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Damage Title",
              ),
              controller: TextEditingController(
                text: widget.damageItem["title"] as String,
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Severity",
              ),
              value: widget.damageItem["severity"] as String,
              items: ['minor', 'moderate', 'severe']
                  .map((severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: "Description",
              ),
              controller: TextEditingController(
                text: widget.damageItem["description"] as String,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Damage assessment updated"),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
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
