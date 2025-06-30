import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommunicationLogWidget extends StatelessWidget {
  final List<dynamic> communications;

  const CommunicationLogWidget({
    super.key,
    required this.communications,
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
                  'Communication Log',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _startNewConversation(context),
                icon: CustomIconWidget(
                  iconName: 'add_comment',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('New'),
                style: AppTheme.lightTheme.textButtonTheme.style,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '${communications.length} messages',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: communications.length,
            separatorBuilder: (context, index) => SizedBox(height: 3.h),
            itemBuilder: (context, index) {
              final message = communications[index] as Map<String, dynamic>;
              return _buildMessageItem(message);
            },
          ),
          if (communications.isEmpty) _buildEmptyState(context),
          SizedBox(height: 3.h),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    String sender = message["sender"] as String;
    String role = message["role"] as String;
    String content = message["message"] as String;
    String timestamp = message["timestamp"] as String;
    bool isFromUser = message["isFromUser"] as bool;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFromUser) ...[
          _buildAvatar(sender, role, isFromUser),
          SizedBox(width: 3.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment:
                isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isFromUser
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft:
                        isFromUser ? Radius.circular(16) : Radius.circular(4),
                    bottomRight:
                        isFromUser ? Radius.circular(4) : Radius.circular(16),
                  ),
                  border: isFromUser
                      ? null
                      : Border.all(
                          color: AppTheme.lightTheme.dividerColor,
                          width: 1,
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFromUser)
                      Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Text(
                              sender,
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                role,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      content,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isFromUser
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  _formatTimestamp(timestamp),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isFromUser) ...[
          SizedBox(width: 3.w),
          _buildAvatar(sender, role, isFromUser),
        ],
      ],
    );
  }

  Widget _buildAvatar(String sender, String role, bool isFromUser) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: isFromUser
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.secondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Center(
        child: isFromUser
            ? CustomIconWidget(
                iconName: 'person',
                color: Colors.white,
                size: 20,
              )
            : Text(
                sender.split(' ').map((name) => name[0]).join(''),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                iconName: 'chat',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No Messages Yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start a conversation with your adjuster',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => _startNewConversation(context),
            icon: CustomIconWidget(
              iconName: 'chat',
              color: Colors.white,
              size: 18,
            ),
            label: Text('Start Conversation'),
            style: AppTheme.lightTheme.elevatedButtonTheme.style,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildQuickActionChip(
                context,
                'Request Update',
                'update',
                () => _sendQuickMessage(context,
                    'Could you please provide an update on my claim status?'),
              ),
              _buildQuickActionChip(
                context,
                'Schedule Call',
                'phone',
                () => _sendQuickMessage(context,
                    'I would like to schedule a call to discuss my claim.'),
              ),
              _buildQuickActionChip(
                context,
                'Ask Question',
                'help',
                () => _startNewConversation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
      BuildContext context, String label, String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _startNewConversation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
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
                'Send Message',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  border: AppTheme.lightTheme.inputDecorationTheme.border,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: AppTheme.lightTheme.outlinedButtonTheme.style,
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message sent successfully'),
                            backgroundColor: AppTheme
                                .lightTheme.snackBarTheme.backgroundColor,
                          ),
                        );
                      },
                      style: AppTheme.lightTheme.elevatedButtonTheme.style,
                      child: Text('Send'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  void _sendQuickMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sent: "$message"'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }
}
