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
    return UserSearchModel(
      name: json['name'] ?? '',
      university: json['university'] ?? '',
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      profileImage: json['profile_image'] ?? '',
      isOnline: json['is_online'] ?? false,
    );
  }
}
