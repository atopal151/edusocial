import '../utils/constants.dart'; // AppConstants.baseUrl buradaysa

class UserSearchModel {
  final int userId;
  final String name;
  final String surname;
  final String username;
  final String university;
  final String degree;
  final String department;
  final String profileImage;
  final bool isActive;
  final bool isFollowing;
  final bool isFollowingPending;

  UserSearchModel({
    required this.userId,
    required this.name,
    required this.surname,
    required this.username,
    required this.university,
    required this.degree,
    required this.department,
    required this.profileImage,
    required this.isActive,
    required this.isFollowing,
    required this.isFollowingPending
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    final avatarPath = json['avatar'];
    final fullAvatarUrl = (avatarPath != null && avatarPath != "")
        ? "${AppConstants.baseUrl}/$avatarPath"
        : ""; // boşsa varsayılan olarak ""

    return UserSearchModel(
      userId: json['id'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      university: json['university'] ?? '',
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      profileImage: fullAvatarUrl,
      isActive: json['is_active'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isFollowingPending: json['is_following_pending'] ?? false,
    );
  }
}
