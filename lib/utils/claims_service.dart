import 'dart:io';
import '../models/insurance_claim.dart';
import '../utils/supabase_service.dart';

class ClaimsService {
  final SupabaseService _supabaseService = SupabaseService();

  /// Get all claims for current user
  Future<List<InsuranceClaim>> getUserClaims({
    ClaimStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      var query = client
          .from('insurance_claims')
          .select('''
            *,
            vehicles(*),
            claimant:user_profiles!claimant_id(*),
            adjuster:user_profiles!adjuster_id(*),
            claim_images(*),
            damage_assessments(*)
          ''')
          .eq('claimant_id', user.id)
          .order('created_at', ascending: false);

      if (status != null) {
        query = query.eq('status', status.dbValue);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      
      return response
          .map((claim) => InsuranceClaim.fromJson(claim as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user claims: $e');
    }
  }

  /// Get claim by ID
  Future<InsuranceClaim?> getClaimById(String claimId) async {
    try {
      final client = await _supabaseService.client;
      
      final response = await client
          .from('insurance_claims')
          .select('''
            *,
            vehicles(*),
            claimant:user_profiles!claimant_id(*),
            adjuster:user_profiles!adjuster_id(*),
            claim_images(*),
            damage_assessments(*)
          ''')
          .eq('id', claimId)
          .maybeSingle();
      return InsuranceClaim.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get claim: $e');
    }
  }

  /// Create new claim
  Future<InsuranceClaim> createClaim({
    required String policyId,
    required String vehicleId,
    required DateTime incidentDate,
    required String incidentLocation,
    required String incidentDescription,
    String? policeReportNumber,
    double? estimatedDamageAmount,
    String? notes,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      final claimData = {
        'policy_id': policyId,
        'vehicle_id': vehicleId,
        'claimant_id': user.id,
        'status': ClaimStatus.draft.dbValue,
        'incident_date': incidentDate.toIso8601String(),
        'incident_location': incidentLocation,
        'incident_description': incidentDescription,
        'police_report_number': policeReportNumber,
        'estimated_damage_amount': estimatedDamageAmount,
        'notes': notes,
      };

      final response = await client
          .from('insurance_claims')
          .insert(claimData)
          .select('''
            *,
            vehicles(*),
            claimant:user_profiles!claimant_id(*),
            adjuster:user_profiles!adjuster_id(*),
            claim_images(*),
            damage_assessments(*)
          ''')
          .single();

      return InsuranceClaim.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create claim: $e');
    }
  }

  /// Update claim
  Future<InsuranceClaim> updateClaim({
    required String claimId,
    DateTime? incidentDate,
    String? incidentLocation,
    String? incidentDescription,
    String? policeReportNumber,
    double? estimatedDamageAmount,
    String? notes,
    ClaimStatus? status,
  }) async {
    try {
      final client = await _supabaseService.client;
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (incidentDate != null) updateData['incident_date'] = incidentDate.toIso8601String();
      if (incidentLocation != null) updateData['incident_location'] = incidentLocation;
      if (incidentDescription != null) updateData['incident_description'] = incidentDescription;
      if (policeReportNumber != null) updateData['police_report_number'] = policeReportNumber;
      if (estimatedDamageAmount != null) updateData['estimated_damage_amount'] = estimatedDamageAmount;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status.dbValue;

      final response = await client
          .from('insurance_claims')
          .update(updateData)
          .eq('id', claimId)
          .select('''
            *,
            vehicles(*),
            claimant:user_profiles!claimant_id(*),
            adjuster:user_profiles!adjuster_id(*),
            claim_images(*),
            damage_assessments(*)
          ''')
          .single();

      return InsuranceClaim.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update claim: $e');
    }
  }

  /// Submit claim (change status from draft to submitted)
  Future<InsuranceClaim> submitClaim(String claimId) async {
    try {
      return await updateClaim(
        claimId: claimId,
        status: ClaimStatus.submitted);
    } catch (e) {
      throw Exception('Failed to submit claim: $e');
    }
  }

  /// Upload claim image
  Future<ClaimImage> uploadClaimImage({
    required String claimId,
    required File imageFile,
    String? description,
    bool isPrimary = false,
    String? assessmentId,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = 'claim_${claimId}_$timestamp.$extension';
      final filePath = 'claims/$claimId/$fileName';

      // Upload to Supabase Storage
      await client.storage
          .from('claim-images')
          .upload(filePath, imageFile);

      // Get public URL
      final imageUrl = client.storage
          .from('claim-images')
          .getPublicUrl(filePath);

      // Save image record to database
      final imageData = {
        'claim_id': claimId,
        'assessment_id': assessmentId,
        'uploaded_by': user.id,
        'image_url': imageUrl,
        'image_name': fileName,
        'image_size': await imageFile.length(),
        'image_type': 'image/$extension',
        'description': description,
        'is_primary': isPrimary,
      };

      final response = await client
          .from('claim_images')
          .insert(imageData)
          .select()
          .single();

      return ClaimImage.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete claim image
  Future<void> deleteClaimImage(String imageId) async {
    try {
      final client = await _supabaseService.client;
      
      // Get image details first
      final imageResponse = await client
          .from('claim_images')
          .select('image_url, image_name')
          .eq('id', imageId)
          .single();

      final imageName = imageResponse['image_name'] as String;
      final claimId = imageResponse['claim_id'] as String;
      final filePath = 'claims/$claimId/$imageName';

      // Delete from storage
      await client.storage
          .from('claim-images')
          .remove([filePath]);

      // Delete from database
      await client
          .from('claim_images')
          .delete()
          .eq('id', imageId);

    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Get claims statistics for dashboard
  Future<Map<String, dynamic>> getClaimsStatistics() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      // Run multiple count queries in parallel
      final results = await Future.wait([
        // Total claims
        client
            .from('insurance_claims')
            .select('*')
            .eq('claimant_id', user.id),
        
        // Pending claims
        client
            .from('insurance_claims')
            .select('*')
            .eq('claimant_id', user.id)
            .eq('status', 'submitted')
            .or('status.eq.under_review,status.eq.pending_docs'),
        
        // Approved claims
        client
            .from('insurance_claims')
            .select('*')
            .eq('claimant_id', user.id)
            .eq('status', 'approved'),
        
        // Total approved amount
        client
            .from('insurance_claims')
            .select('approved_amount')
            .eq('claimant_id', user.id)
            .eq('status', 'approved'),
      ]);

      final totalClaims = results[0].count ?? 0;
      final pendingClaims = results[1].count ?? 0;
      final approvedClaims = results[2].count ?? 0;
      
      double totalApprovedAmount = 0.0;
      if (results[3] is List) {
        for (final claim in results[3] as List) {
          final amount = claim['approved_amount'];
          if (amount != null) {
            totalApprovedAmount += (amount is num) ? amount.toDouble() : 0.0;
          }
        }
      }

      return {
        'total_claims': totalClaims,
        'pending_claims': pendingClaims,
        'approved_claims': approvedClaims,
        'denied_claims': totalClaims - pendingClaims - approvedClaims,
        'total_approved_amount': totalApprovedAmount,
        'average_claim_amount': approvedClaims > 0 
            ? totalApprovedAmount / approvedClaims 
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Add claim activity/timeline entry
  Future<void> addClaimActivity({
    required String claimId,
    required String activityType,
    required String description,
    String? oldValue,
    String? newValue,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      final activityData = {
        'claim_id': claimId,
        'user_id': user?.id,
        'activity_type': activityType,
        'description': description,
        'old_value': oldValue,
        'new_value': newValue,
        'metadata': metadata,
      };

      await client
          .from('claim_activities')
          .insert(activityData);

    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  /// Get claim activities
  Future<List<Map<String, dynamic>>> getClaimActivities(String claimId) async {
    try {
      final client = await _supabaseService.client;
      
      final response = await client
          .from('claim_activities')
          .select('''
            *,
            user_profiles(full_name, profile_image_url)
          ''')
          .eq('claim_id', claimId)
          .order('created_at', ascending: false);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  /// Get user vehicles
  Future<List<Vehicle>> getUserVehicles() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      final response = await client
          .from('vehicles')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map((vehicle) => Vehicle.fromJson(vehicle))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }
}