import '../models/user_profile.dart';

enum ClaimStatus {
  draft,
  submitted,
  underReview,
  pendingDocs,
  approved,
  denied,
  processingPayment,
  completed,
  cancelled
}

enum DamageSeverity { minor, moderate, major, totalLoss }

enum VehicleType { car, truck, motorcycle, suv, van, other }

class InsuranceClaim {
  final String id;
  final String claimNumber;
  final String policyId;
  final String vehicleId;
  final String claimantId;
  final String? adjusterId;
  final ClaimStatus status;
  final DateTime incidentDate;
  final DateTime reportedDate;
  final String incidentLocation;
  final String incidentDescription;
  final String? policeReportNumber;
  final double? estimatedDamageAmount;
  final double? approvedAmount;
  final double? deductibleAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated through joins)
  final Vehicle? vehicle;
  final UserProfile? claimant;
  final UserProfile? adjuster;
  final List<ClaimImage>? images;
  final List<DamageAssessment>? assessments;

  InsuranceClaim({
    required this.id,
    required this.claimNumber,
    required this.policyId,
    required this.vehicleId,
    required this.claimantId,
    this.adjusterId,
    required this.status,
    required this.incidentDate,
    required this.reportedDate,
    required this.incidentLocation,
    required this.incidentDescription,
    this.policeReportNumber,
    this.estimatedDamageAmount,
    this.approvedAmount,
    this.deductibleAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
    this.claimant,
    this.adjuster,
    this.images,
    this.assessments,
  });

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    return InsuranceClaim(
      id: json['id'] as String,
      claimNumber: json['claim_number'] as String,
      policyId: json['policy_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      claimantId: json['claimant_id'] as String,
      adjusterId: json['adjuster_id'] as String?,
      status: _parseClaimStatus(json['status'] as String),
      incidentDate: DateTime.parse(json['incident_date'] as String),
      reportedDate: DateTime.parse(json['reported_date'] as String),
      incidentLocation: json['incident_location'] as String,
      incidentDescription: json['incident_description'] as String,
      policeReportNumber: json['police_report_number'] as String?,
      estimatedDamageAmount: _parseDouble(json['estimated_damage_amount']),
      approvedAmount: _parseDouble(json['approved_amount']),
      deductibleAmount: _parseDouble(json['deductible_amount']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      vehicle: json['vehicles'] != null 
          ? Vehicle.fromJson(json['vehicles'] as Map<String, dynamic>)
          : null,
      claimant: json['claimant'] != null
          ? UserProfile.fromJson(json['claimant'] as Map<String, dynamic>)
          : null,
      adjuster: json['adjuster'] != null
          ? UserProfile.fromJson(json['adjuster'] as Map<String, dynamic>)
          : null,
      images: json['claim_images'] != null
          ? (json['claim_images'] as List)
              .map((img) => ClaimImage.fromJson(img as Map<String, dynamic>))
              .toList()
          : null,
      assessments: json['damage_assessments'] != null
          ? (json['damage_assessments'] as List)
              .map((assess) => DamageAssessment.fromJson(assess as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claim_number': claimNumber,
      'policy_id': policyId,
      'vehicle_id': vehicleId,
      'claimant_id': claimantId,
      'adjuster_id': adjusterId,
      'status': status.dbValue,
      'incident_date': incidentDate.toIso8601String(),
      'reported_date': reportedDate.toIso8601String(),
      'incident_location': incidentLocation,
      'incident_description': incidentDescription,
      'police_report_number': policeReportNumber,
      'estimated_damage_amount': estimatedDamageAmount,
      'approved_amount': approvedAmount,
      'deductible_amount': deductibleAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ClaimStatus _parseClaimStatus(String status) {
    switch (status) {
      case 'draft':
        return ClaimStatus.draft;
      case 'submitted':
        return ClaimStatus.submitted;
      case 'under_review':
        return ClaimStatus.underReview;
      case 'pending_docs':
        return ClaimStatus.pendingDocs;
      case 'approved':
        return ClaimStatus.approved;
      case 'denied':
        return ClaimStatus.denied;
      case 'processing_payment':
        return ClaimStatus.processingPayment;
      case 'completed':
        return ClaimStatus.completed;
      case 'cancelled':
        return ClaimStatus.cancelled;
      default:
        return ClaimStatus.draft;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get statusDisplayName => status.displayName;
  String get formattedEstimatedAmount => estimatedDamageAmount != null 
      ? '\$${estimatedDamageAmount!.toStringAsFixed(2)}'
      : 'Pending';
  String get formattedApprovedAmount => approvedAmount != null 
      ? '\$${approvedAmount!.toStringAsFixed(2)}'
      : 'Pending';

  ClaimImage? get primaryImage => images?.firstWhere(
    (img) => img.isPrimary,
    orElse: () => images?.isNotEmpty == true ? images!.first : ClaimImage.empty(),
  );

  bool get hasImages => images?.isNotEmpty == true;
  int get imageCount => images?.length ?? 0;

  bool get canEdit => [ClaimStatus.draft, ClaimStatus.submitted].contains(status);
  bool get isActive => ![ClaimStatus.completed, ClaimStatus.cancelled, ClaimStatus.denied].contains(status);
}

extension ClaimStatusExtension on ClaimStatus {
  String get dbValue {
    switch (this) {
      case ClaimStatus.draft:
        return 'draft';
      case ClaimStatus.submitted:
        return 'submitted';
      case ClaimStatus.underReview:
        return 'under_review';
      case ClaimStatus.pendingDocs:
        return 'pending_docs';
      case ClaimStatus.approved:
        return 'approved';
      case ClaimStatus.denied:
        return 'denied';
      case ClaimStatus.processingPayment:
        return 'processing_payment';
      case ClaimStatus.completed:
        return 'completed';
      case ClaimStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.pendingDocs:
        return 'Pending Documents';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.denied:
        return 'Denied';
      case ClaimStatus.processingPayment:
        return 'Processing Payment';
      case ClaimStatus.completed:
        return 'Completed';
      case ClaimStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Vehicle {
  final String id;
  final String ownerId;
  final String? policyId;
  final VehicleType vehicleType;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final String? color;
  final int? currentMileage;
  final double? estimatedValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.ownerId,
    this.policyId,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    this.color,
    this.currentMileage,
    this.estimatedValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      policyId: json['policy_id'] as String?,
      vehicleType: _parseVehicleType(json['vehicle_type'] as String),
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String?,
      licensePlate: json['license_plate'] as String?,
      color: json['color'] as String?,
      currentMileage: json['current_mileage'] as int?,
      estimatedValue: InsuranceClaim._parseDouble(json['estimated_value']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static VehicleType _parseVehicleType(String type) {
    switch (type) {
      case 'car':
        return VehicleType.car;
      case 'truck':
        return VehicleType.truck;
      case 'motorcycle':
        return VehicleType.motorcycle;
      case 'suv':
        return VehicleType.suv;
      case 'van':
        return VehicleType.van;
      case 'other':
        return VehicleType.other;
      default:
        return VehicleType.car;
    }
  }

  String get displayName => '$year $make $model';
  String get formattedValue => estimatedValue != null 
      ? '\$${estimatedValue!.toStringAsFixed(2)}'
      : 'N/A';
}

class ClaimImage {
  final String id;
  final String claimId;
  final String? assessmentId;
  final String? uploadedBy;
  final String imageUrl;
  final String imageName;
  final int? imageSize;
  final String? imageType;
  final String? description;
  final bool isPrimary;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  ClaimImage({
    required this.id,
    required this.claimId,
    this.assessmentId,
    this.uploadedBy,
    required this.imageUrl,
    required this.imageName,
    this.imageSize,
    this.imageType,
    this.description,
    required this.isPrimary,
    this.metadata,
    required this.createdAt,
  });

  factory ClaimImage.fromJson(Map<String, dynamic> json) {
    return ClaimImage(
      id: json['id'] as String,
      claimId: json['claim_id'] as String,
      assessmentId: json['assessment_id'] as String?,
      uploadedBy: json['uploaded_by'] as String?,
      imageUrl: json['image_url'] as String,
      imageName: json['image_name'] as String,
      imageSize: json['image_size'] as int?,
      imageType: json['image_type'] as String?,
      description: json['description'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory ClaimImage.empty() {
    return ClaimImage(
      id: '',
      claimId: '',
      imageUrl: '',
      imageName: '',
      isPrimary: false,
      createdAt: DateTime.now(),
    );
  }
}

class DamageAssessment {
  final String id;
  final String claimId;
  final String? assessorId;
  final String assessmentType;
  final DamageSeverity severity;
  final String damageDescription;
  final List<String>? affectedAreas;
  final String? repairRecommendations;
  final double? estimatedCost;
  final double? confidenceScore;
  final bool isFinal;
  final DateTime createdAt;
  final DateTime updatedAt;

  DamageAssessment({
    required this.id,
    required this.claimId,
    this.assessorId,
    required this.assessmentType,
    required this.severity,
    required this.damageDescription,
    this.affectedAreas,
    this.repairRecommendations,
    this.estimatedCost,
    this.confidenceScore,
    required this.isFinal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DamageAssessment.fromJson(Map<String, dynamic> json) {
    return DamageAssessment(
      id: json['id'] as String,
      claimId: json['claim_id'] as String,
      assessorId: json['assessor_id'] as String?,
      assessmentType: json['assessment_type'] as String,
      severity: _parseDamageSeverity(json['severity'] as String),
      damageDescription: json['damage_description'] as String,
      affectedAreas: json['affected_areas'] != null
          ? List<String>.from(json['affected_areas'] as List)
          : null,
      repairRecommendations: json['repair_recommendations'] as String?,
      estimatedCost: InsuranceClaim._parseDouble(json['estimated_cost']),
      confidenceScore: InsuranceClaim._parseDouble(json['confidence_score']),
      isFinal: json['is_final'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static DamageSeverity _parseDamageSeverity(String severity) {
    switch (severity) {
      case 'minor':
        return DamageSeverity.minor;
      case 'moderate':
        return DamageSeverity.moderate;
      case 'major':
        return DamageSeverity.major;
      case 'total_loss':
        return DamageSeverity.totalLoss;
      default:
        return DamageSeverity.minor;
    }
  }

  String get formattedCost => estimatedCost != null 
      ? '\$${estimatedCost!.toStringAsFixed(2)}'
      : 'Pending';
  
  String get confidencePercentage => confidenceScore != null 
      ? '${(confidenceScore! * 100).round()}%'
      : 'N/A';
}