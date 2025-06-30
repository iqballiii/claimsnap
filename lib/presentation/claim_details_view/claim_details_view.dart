import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_assessment_widget.dart';
import './widgets/claim_info_section_widget.dart';
import './widgets/claim_status_banner_widget.dart';
import './widgets/claim_timeline_widget.dart';
import './widgets/communication_log_widget.dart';
import './widgets/documents_section_widget.dart';
import './widgets/photo_gallery_widget.dart';
import './widgets/status_actions_widget.dart';

class ClaimDetailsView extends StatefulWidget {
  const ClaimDetailsView({super.key});

  @override
  State<ClaimDetailsView> createState() => _ClaimDetailsViewState();
}

class _ClaimDetailsViewState extends State<ClaimDetailsView> {
  final ScrollController _scrollController = ScrollController();

  // Mock claim data
  final Map<String, dynamic> claimData = {
    "claimId": "CLM-2024-001234",
    "status": "processing",
    "lastUpdated": "2024-01-15T10:30:00Z",
    "incidentDate": "2024-01-10",
    "location": "Downtown Parking Garage, 123 Main St",
    "adjusterName": "Sarah Johnson",
    "adjusterPhone": "+1-555-0123",
    "adjusterEmail": "sarah.johnson@insurance.com",
    "estimatedAmount": "\$4,250.00",
    "deductible": "\$500.00",
    "policyNumber": "POL-789456123",
    "vehicleInfo": "2022 Honda Civic - License: ABC123",
    "damagePhotos": [
      "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg",
      "https://images.pexels.com/photos/2244746/pexels-photo-2244746.jpeg",
      "https://images.pexels.com/photos/3807277/pexels-photo-3807277.jpeg",
      "https://images.pexels.com/photos/1119796/pexels-photo-1119796.jpeg"
    ],
    "aiAssessment": {
      "damageType": "Front bumper impact, headlight damage",
      "severity": "Moderate",
      "repairEstimate": "\$3,800 - \$4,500",
      "confidence": "94%",
      "details":
          "AI analysis detected significant front-end damage including bumper deformation and left headlight assembly damage. Recommended professional inspection for hidden structural damage."
    },
    "documents": [
      {
        "name": "Police Report",
        "type": "PDF",
        "size": "2.4 MB",
        "uploadDate": "2024-01-11",
        "url": "https://example.com/police-report.pdf"
      },
      {
        "name": "Repair Estimate",
        "type": "PDF",
        "size": "1.8 MB",
        "uploadDate": "2024-01-13",
        "url": "https://example.com/repair-estimate.pdf"
      }
    ],
    "timeline": [
      {
        "step": "Claim Submitted",
        "status": "completed",
        "date": "2024-01-10",
        "description": "Initial claim filed with photos"
      },
      {
        "step": "AI Assessment",
        "status": "completed",
        "date": "2024-01-11",
        "description": "Automated damage analysis completed"
      },
      {
        "step": "Adjuster Review",
        "status": "current",
        "date": "2024-01-15",
        "description": "Professional review in progress"
      },
      {
        "step": "Settlement Offer",
        "status": "pending",
        "date": null,
        "description": "Awaiting adjuster decision"
      },
      {
        "step": "Claim Closed",
        "status": "pending",
        "date": null,
        "description": "Final resolution"
      }
    ],
    "communications": [
      {
        "sender": "Sarah Johnson",
        "role": "Adjuster",
        "message":
            "I've reviewed your photos and will schedule an in-person inspection for next week. The damage appears consistent with your description.",
        "timestamp": "2024-01-15T09:15:00Z",
        "isFromUser": false
      },
      {
        "sender": "You",
        "role": "Policyholder",
        "message":
            "Thank you for the update. I'm available Monday through Wednesday for the inspection.",
        "timestamp": "2024-01-15T10:30:00Z",
        "isFromUser": true
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: AppTheme.lightTheme.appBarTheme.elevation,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        'Claim Details',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      actions: [
        IconButton(
          onPressed: () => _showMoreOptions(),
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          ClaimStatusBannerWidget(claimData: claimData),
          SizedBox(height: 3.h),
          ClaimInfoSectionWidget(claimData: claimData),
          SizedBox(height: 3.h),
          ClaimTimelineWidget(timeline: claimData["timeline"] as List),
          SizedBox(height: 3.h),
          PhotoGalleryWidget(photos: claimData["damagePhotos"] as List<String>),
          SizedBox(height: 3.h),
          AiAssessmentWidget(
              assessment: claimData["aiAssessment"] as Map<String, dynamic>),
          SizedBox(height: 3.h),
          DocumentsSectionWidget(documents: claimData["documents"] as List),
          SizedBox(height: 3.h),
          CommunicationLogWidget(
              communications: claimData["communications"] as List),
          SizedBox(height: 3.h),
          StatusActionsWidget(status: claimData["status"] as String),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    String status = claimData["status"] as String;
    String actionText = '';
    IconData actionIcon = Icons.add;

    switch (status.toLowerCase()) {
      case 'processing':
        actionText = 'Upload Photos';
        actionIcon = Icons.camera_alt;
        break;
      case 'pending':
        actionText = 'Contact Adjuster';
        actionIcon = Icons.phone;
        break;
      case 'approved':
        actionText = 'Accept Settlement';
        actionIcon = Icons.check_circle;
        break;
      case 'rejected':
        actionText = 'Appeal Decision';
        actionIcon = Icons.gavel;
        break;
      default:
        actionText = 'Quick Action';
        actionIcon = Icons.add;
    }

    return FloatingActionButton.extended(
      onPressed: () => _handleQuickAction(status),
      backgroundColor:
          AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
      foregroundColor:
          AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
      icon: CustomIconWidget(
        iconName: actionIcon.toString().split('.').last,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        actionText,
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMoreOptions() {
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
            _buildOptionTile('Share Claim', 'share', () {
              Navigator.pop(context);
              _shareClaim();
            }),
            _buildOptionTile('Export PDF', 'picture_as_pdf', () {
              Navigator.pop(context);
              _exportPDF();
            }),
            _buildOptionTile('Print Details', 'print', () {
              Navigator.pop(context);
              _printDetails();
            }),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _handleQuickAction(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        Navigator.pushNamed(context, '/camera-capture-interface');
        break;
      case 'pending':
        _contactAdjuster();
        break;
      case 'approved':
        _acceptSettlement();
        break;
      case 'rejected':
        _appealDecision();
        break;
      default:
        _showDefaultAction();
    }
  }

  void _contactAdjuster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        title: Text(
          'Contact Adjuster',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Would you like to call or email ${claimData["adjusterName"]}?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement email functionality
            },
            child: Text('Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement call functionality
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _acceptSettlement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.dialogBackgroundColor,
        title: Text(
          'Accept Settlement',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to accept the settlement offer of ${claimData["estimatedAmount"]}?',
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
              // Implement settlement acceptance
            },
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _appealDecision() {
    Navigator.pushNamed(context, '/claims-dashboard');
  }

  void _showDefaultAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quick action not available for current status'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _shareClaim() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing claim details...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _exportPDF() {
    // Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting claim as PDF...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  void _printDetails() {
    // Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preparing claim details for printing...'),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
