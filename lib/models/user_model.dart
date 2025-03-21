class ProfileModel {
  final String schoolLogo;
  final String schoolName;
  final String schoolDepartment;
  final String schoolGrade;
  final String birthDate;
  final String email;
  final List<String> courses;
 final List<GroupModel> joinedGroups; // Katıldığı gruplar

  ProfileModel({
    required this.schoolLogo,
    required this.schoolName,
    required this.schoolDepartment,
    required this.schoolGrade,
    required this.birthDate,
    required this.email,
    required this.courses,
    required this.joinedGroups, // Katıldığı gruplar
  });

  /// JSON'dan model nesnesine çevirme
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      schoolLogo: json['schoolLogo'],
      schoolName: json['schoolName'],
      schoolDepartment: json['schoolDepartment'],
      schoolGrade: json['schoolGrade'],
      birthDate: json['birthDate'],
      email: json['email'],
      courses: List<String>.from(json['courses']),
         joinedGroups: (json['joinedGroups'] as List)
          .map((group) => GroupModel.fromJson(group))
          .toList(), // Katıldığı gruplar
    );
  }
}


class GroupModel {
  final String groupName;
  final String groupImage;  // Kapak fotoğrafı
  final String groupAvatar; // Grup profili (yuvarlak)
  final int memberCount;    // Üye sayısı

  GroupModel({
    required this.groupName,
    required this.groupImage,
    required this.groupAvatar,
    required this.memberCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupName: json['groupName'],
      groupImage: json['groupImage'],
      groupAvatar: json['groupAvatar'],
      memberCount: json['memberCount'],
    );
  }
}