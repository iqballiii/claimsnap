import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../utils/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserProfile? _currentUserProfile;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);

      // Get current user
      _currentUser = await _authService.currentUser;

      // Get user profile if user exists
      if (_currentUser != null) {
        try {
          _currentUserProfile = await _authService.currentUserProfile;
        } catch (e) {
          // Profile might not exist yet, clear user to force re-login
          _currentUser = null;
          debugPrint('Profile not found for user: $e');
        }
      }

      _isInitialized = true;
      _setLoading(false);

      // Listen to auth state changes
      _authService.authStateChanges.listen((AuthState data) {
        _handleAuthStateChange(data);
      });
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
      _setLoading(false);
    }
  }

  /// Handle auth state changes
  void _handleAuthStateChange(AuthState authState) async {
    final event = authState.event;
    final user = authState.session?.user;

    switch (event) {
      case AuthChangeEvent.signedIn:
        _currentUser = user;
        if (user != null) {
          try {
            _currentUserProfile = await _authService.currentUserProfile;
          } catch (e) {
            debugPrint('Error loading profile after sign in: $e');
            _currentUserProfile = null;
          }
        }
        _clearError();
        notifyListeners();
        break;

      case AuthChangeEvent.signedOut:
        _currentUser = null;
        _currentUserProfile = null;
        _clearError();
        notifyListeners();
        break;

      case AuthChangeEvent.userUpdated:
        _currentUser = user;
        if (user != null) {
          try {
            _currentUserProfile = await _authService.currentUserProfile;
          } catch (e) {
            debugPrint('Error loading profile after user update: $e');
          }
        }
        notifyListeners();
        break;

      case AuthChangeEvent.passwordRecovery:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.initialSession:
        // Handle these events if needed
        break;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        _currentUserProfile = await _authService.currentUserProfile;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid credentials');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithPassword({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.customer,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signUpWithPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (response.user != null) {
        _currentUser = response.user;
        // Profile will be created automatically via trigger
        // Wait a moment then try to load profile
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          _currentUserProfile = await _authService.currentUserProfile;
        } catch (e) {
          debugPrint('Profile not ready yet: $e');
        }
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign up failed: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();

      _currentUser = null;
      _currentUserProfile = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${_getErrorMessage(e)}');
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password reset failed: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = await _authService.updateUserProfile(
        fullName: fullName,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      _currentUserProfile = updatedProfile;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profile update failed: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    if (_currentUser == null) return;

    try {
      _currentUserProfile = await _authService.currentUserProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh profile: $e');
    }
  }

  /// Update password
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updatePassword(newPassword: newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Password update failed: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUserProfile?.role == role;
  }

  /// Check if user is admin or higher
  bool get isAdminOrHigher => _currentUserProfile?.isAdjusterOrHigher ?? false;

  /// Check if user is customer
  bool get isCustomer => _currentUserProfile?.isCustomer ?? true;

}