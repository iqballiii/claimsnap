import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DocumentsSectionWidget extends StatelessWidget {
  final List<dynamic> documents;

  const DocumentsSectionWidget({
    super.key,
    required this.documents,
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
                  'Documents',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addDocument(context),
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('Add'),
                style: AppTheme.lightTheme.textButtonTheme.style,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '${documents.length} documents uploaded',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final document = documents[index] as Map<String, dynamic>;
              return _buildDocumentItem(context, document);
            },
          ),
          if (documents.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, Map<String, dynamic> document) {
    String name = document["name"] as String;
    String type = document["type"] as String;
    String size = document["size"] as String;
    String uploadDate = document["uploadDate"] as String;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getDocumentTypeColor(type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getDocumentTypeIcon(type),
                color: _getDocumentTypeColor(type),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: _getDocumentTypeColor(type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '•',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      size,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Uploaded ${_formatDate(uploadDate)}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleDocumentAction(context, document, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'visibility',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('View'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'download',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Download'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.errorLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.errorLight),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'description',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No Documents Yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add supporting documents to strengthen your claim',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => _addDocument(null),
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 18,
            ),
            label: Text('Add Document'),
            style: AppTheme.lightTheme.elevatedButtonTheme.style,
          ),
        ],
      ),
    );
  }

  Color _getDocumentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return AppTheme.errorLight;
      case 'doc':
      case 'docx':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getDocumentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'insert_drive_file';
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _addDocument(BuildContext? context) {
    if (context == null) return;

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
              'Add Document',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildDocumentOption(
              context,
              'Take Photo',
              'camera_alt',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera-capture-interface');
              },
            ),
            SizedBox(height: 2.h),
            _buildDocumentOption(
              context,
              'Choose from Files',
              'folder',
              () {
                Navigator.pop(context);
                // Implement file picker
              },
            ),
            SizedBox(height: 2.h),
            _buildDocumentOption(
              context,
              'Scan Document',
              'scanner',
              () {
                Navigator.pop(context);
                // Implement document scanner
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentOption(
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

  void _handleDocumentAction(
      BuildContext context, Map<String, dynamic> document, String action) {
    switch (action) {
      case 'view':
        _viewDocument(context, document);
        break;
      case 'download':
        _downloadDocument(context, document);
        break;
      case 'share':
        _shareDocument(context, document);
        break;
      case 'delete':
        _deleteDocument(context, document);
        break;
    }
  }

  void _viewDocument(BuildContext context, Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${document["name"]}...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _downloadDocument(BuildContext context, Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document["name"]}...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _shareDocument(BuildContext context, Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${document["name"]}...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _deleteDocument(BuildContext context, Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        title: Text(
          'Delete Document',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "${document["name"]}"? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Document deleted'),
                  backgroundColor:
                      AppTheme.lightTheme.snackBarTheme.backgroundColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
