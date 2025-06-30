
enum UserRole { admin, manager, adjuster, customer }

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: _parseUserRole(json['role'] as String),
      profileImageUrl: json['profile_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'adjuster':
        return UserRole.adjuster;
      case 'customer':
        return UserRole.customer;
      default:
        return UserRole.customer;
    }
  }

  bool get isAdjusterOrHigher =>
      [UserRole.admin, UserRole.manager, UserRole.adjuster].contains(role);
  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.adjuster:
        return 'Claims Adjuster';
      case UserRole.customer:
        return 'Customer';
    }
  }
}
