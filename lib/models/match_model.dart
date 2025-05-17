class MatchModel {
  final String name;
  final String profileImage;
  final bool isOnline;
  final DateTime? birthday;
  final String schoolName;
  final String schoolLogo;
  final String department;
  final String about;
  final int grade;
  final List<String> matchedTopics;

  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  MatchModel({
    required this.name,
    required this.profileImage,
    required this.isOnline,
    required this.birthday,
    required this.schoolName,
    required this.schoolLogo,
    required this.department,
    required this.about,
    required this.grade,
    required this.matchedTopics,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final user = json['matched_user'] ?? {};
    return MatchModel(
      name: user['name'] ?? '',
      profileImage: user['avatar_url'] ?? '',
      isOnline: user['is_online'] ?? false,
      birthday: user['birthday'] != null ? DateTime.tryParse(user['birthday']) : null,
      schoolName: user['school']?['name'] ?? '',
      schoolLogo: user['school']?['logo'] ?? '',
      department: user['school_department']?['name'] ?? '',
      about: user['about'] ?? '',
      grade: user['grade'] ?? 0,
      matchedTopics: [json['matched_lesson'] ?? ''],
    );
  }
}
