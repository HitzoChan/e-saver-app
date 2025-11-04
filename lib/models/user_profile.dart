import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  factory UserProfile.create({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: now,
      lastLoginAt: now,
      preferences: {
        'theme': 'light',
        'notifications': true,
        'currency': 'PHP',
      },
    );
  }

  bool get isValid =>
      userId.isNotEmpty &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      email.contains('@');

  @override
  String toString() {
    return 'UserProfile(userId: $userId, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
