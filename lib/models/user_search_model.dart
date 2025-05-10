import '../utils/constants.dart'; // AppConstants.baseUrl buradaysa

class UserSearchModel {
  final String name;
  final String university;
  final String degree;
  final String department;
  final String profileImage;
  final bool isOnline;

  UserSearchModel({
    required this.name,
    required this.university,
    required this.degree,
    required this.department,
    required this.profileImage,
    required this.isOnline,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    final avatarPath = json['avatar'];
    final fullAvatarUrl = (avatarPath != null && avatarPath != "")
        ? "${AppConstants.baseUrl}/$avatarPath"
        : ""; // boşsa varsayılan olarak ""

    return UserSearchModel(
      name: json['name'] ?? '',
      university: json['university'] ?? '',
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      profileImage: fullAvatarUrl,
      isOnline: json['is_online'] ?? false,
    );
  }
}
