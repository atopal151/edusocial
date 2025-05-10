import '../utils/constants.dart'; // AppConstants.baseUrl buradaysa

class UserSearchModel {
  final String name;
  final String surname;
  final String username;
  final String university;
  final String degree;
  final String department;
  final String profileImage;
  final bool isActive;

  UserSearchModel({
    required this.name,
    required this.surname,
    required this.username,
    required this.university,
    required this.degree,
    required this.department,
    required this.profileImage,
    required this.isActive,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    final avatarPath = json['avatar'];
    final fullAvatarUrl = (avatarPath != null && avatarPath != "")
        ? "${AppConstants.baseUrl}/$avatarPath"
        : ""; // boşsa varsayılan olarak ""

    return UserSearchModel(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
      university: json['university'] ?? '',
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      profileImage: fullAvatarUrl,
      isActive: json['is_active'] ?? false,
    );
  }
}
