import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  /// Current user session
  Future<Session?> get currentSession async {
    final client = await _supabaseService.client;
    return client.auth.currentSession;
  }

  /// Current user
  Future<User?> get currentUser async {
    final client = await _supabaseService.client;
    return client.auth.currentUser;
  }

  /// Current user profile
  Future<UserProfile?> get currentUserProfile async {
    try {
      final user = await currentUser;
      if (user == null) return null;

      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> get isAuthenticated async {
    final user = await currentUser;
    return user != null;
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Authentication failed');
      }

      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final client = await _supabaseService.client;
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      final client = await _supabaseService.client;
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Password update failed');
      }

      return response;
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final user = await currentUser;
      if (user == null) throw Exception('User not authenticated');

      final client = await _supabaseService.client;

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }

      if (updateData.isEmpty) {
        throw Exception('No data to update');
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges async* {
    final client = await _supabaseService.client;
    yield* client.auth.onAuthStateChange;
  }

  /// Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final client = await _supabaseService.client;
      final response = await client.auth.refreshSession();

      if (response.session == null) {
        throw Exception('Session refresh failed');
      }

      return response;
    } catch (e) {
      throw Exception('Session refresh failed: $e');
    }
  }
}
