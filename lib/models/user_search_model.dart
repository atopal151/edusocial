class UserSearchModel {
  final int userId;
  final String name;
  final String surname;
  final String username;
  final String profileImage;
  final bool isActive;
  final bool isFollowing;
  final bool isFollowingPending;

  // Opsiyonel alanlar varsa nullable yap
  final String? university;
  final String? degree;
  final String? department;

  UserSearchModel({
    required this.userId,
    required this.name,
    required this.surname,
    required this.username,
    required this.profileImage,
    required this.isActive,
    required this.isFollowing,
    required this.isFollowingPending,
    this.university,
    this.degree,
    this.department,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      userId: json['id'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['avatar_url'] ?? '', // ✅ DOĞRU alan bu!
      isActive: json['is_active'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isFollowingPending: json['is_following_pending'] ?? false,
      university: json['university'],
      degree: json['degree'],
      department: json['department'],
    );
  }
}
