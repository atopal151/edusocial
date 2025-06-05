class MatchModel {
  final int userId;
  final String name;
  final String username;
  final String profileImage;
  final bool isOnline;
  final DateTime? birthday;
  final String schoolName;
  final String schoolLogo;
  final String department;
  final String about;
  final int grade;
  final List<String> matchedTopics;
  final bool isFollowing;

  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  MatchModel({
    required this.userId,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.isOnline,
    required this.birthday,
    required this.schoolName,
    required this.schoolLogo,
    required this.department,
    required this.about,
    required this.grade,
    required this.matchedTopics,
    required this.isFollowing,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final user = json['matched_user'] ?? {};

    return MatchModel(
      userId: user['id'] ?? 0,
      name: user['name'] ?? '',
      username: user['username'] ?? '',
      profileImage: user['avatar_url'] ?? '',
      isOnline: user['is_online'] ?? false,
      birthday:
          user['birthday'] != null ? DateTime.tryParse(user['birthday']) : null,
      schoolName: user['school']?['name'] ?? '',
      schoolLogo: user['school']?['logo'] ?? '',
      department: user['school_department']?['title'] ??
          '', // dikkat et name yerine title gelmiş olabilir
      about: user['bio'] ?? '',
      grade: user['school_grade'] != null
          ? int.tryParse(user['school_grade'].toString()) ?? 0
          : 0,
      matchedTopics:
          json['matched_lesson'] != null ? [json['matched_lesson']] : [],
      isFollowing: user['is_following'] ?? false,
    );
  }

  MatchModel copyWith({bool? isFollowing}) {
    return MatchModel(
      userId: userId,
      name: name,
      username: username,
      profileImage: profileImage,
      isOnline: isOnline,
      birthday: birthday,
      schoolName: schoolName,
      schoolLogo: schoolLogo,
      department: department,
      about: about,
      grade: grade,
      matchedTopics: matchedTopics,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
